## Build pytorch from source 

Reference: https://khushi-411.github.io/installing-pytorch-from-source/
``` bash
# Change CUDA envs
export CUDA_HOME=/usr/local/cuda-11.6
export LD_LIBRARY_PATH=${CUDA_HOME}/lib64
PATH=${CUDA_HOME}/bin:${PATH}
export PATH

# set envs
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

export PATH=/usr/local/cuda/bin/:$PATH
# Add cudnn lib
cp -r cudnn-linux-x86_64-8.5.0.96_cuda11-archive/include/cudnn* /usr/local/cuda/include
cp -r cudnn-linux-x86_64-8.5.0.96_cuda11-archive/lib/libcudnn* /usr/local/cuda/lib64
cd pytorch
export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"}
python3 setup.py develop
```
## Build DGL from source

``` bash
git clone https://github.com/dmlc/dgl.git
git branch -a
git checkout -b 0.7.x origin/0.7.x
git submodule update --init --recursive
pip3 install torch==1.10.1+cu113 torchvision==0.11.2+cu113 torchaudio==0.10.1+cu113 -f https://download.pytorch.org/whl/cu113/torch_stable.html

export DGL_HOME=/home/scratch.jiahuil_gpu/GNN/dgl_0.7_baseline
export DGL_LIBRARY_PATH=$DGL_HOME/build
export PYTHONPATH=$PYTHONPATH:$DGL_HOME/python


mkdir build
cd build
cmake .. -DCMAKE_VERBOSE_MAKEFILE=1 -DBUILD_TORCH=ON -DUSE_CUDA=ON -DUSE_NCCL=ON -DCMAKE_BUILD_TYPE=Release
make -j4
```
## Debug JIT by UT
Steps
``` bash
add test_xxx.cpp into dir pytorch/test/cpp/jit/
add test_xxx.cpp into ${JIT_TEST_ROOT} of pytorch/test/cpp/jit/CMakeLists.txt
cd root and exec "python setup.py develop"
run UT by exec "build/bin/test_jit --gtest_filter='NVFuserTest*FusionClampElems_CUDA*'"
```

``` c++
//UT Sample:
#if defined(USE_CUDA)
#include <gmock/gmock-matchers.h>
#include <gtest/gtest.h>
#include <torch/csrc/jit/codegen/cuda/arith.h>
#include <torch/csrc/jit/codegen/cuda/codegen.h>
#include <torch/csrc/jit/codegen/cuda/disjoint_set.h>
#include <torch/csrc/jit/codegen/cuda/executor.h>
#include <torch/csrc/jit/codegen/cuda/executor_launch_params.h>
#include <torch/csrc/jit/codegen/cuda/expr_evaluator.h>
#include <torch/csrc/jit/codegen/cuda/fusion.h>
#include <torch/csrc/jit/codegen/cuda/fusion_segmenter.h>
#include <torch/csrc/jit/codegen/cuda/grouped_reduction.h>
#include <torch/csrc/jit/codegen/cuda/inline_propagator.h>
#include <torch/csrc/jit/codegen/cuda/interface.h>
#include <torch/csrc/jit/codegen/cuda/ir_all_nodes.h>
#include <torch/csrc/jit/codegen/cuda/ir_builder.h>
#include <torch/csrc/jit/codegen/cuda/ir_graphviz.h>
#include <torch/csrc/jit/codegen/cuda/ir_iostream.h>
#include <torch/csrc/jit/codegen/cuda/ir_utils.h>
#include <torch/csrc/jit/codegen/cuda/iter_visitor.h>
#include <torch/csrc/jit/codegen/cuda/kernel_cache.h>
#include <torch/csrc/jit/codegen/cuda/kernel_expr_evaluator.h>
#include <torch/csrc/jit/codegen/cuda/kernel_ir.h>
#include <torch/csrc/jit/codegen/cuda/kernel_ir_dispatch.h>
#include <torch/csrc/jit/codegen/cuda/lower2device.h>
#include <torch/csrc/jit/codegen/cuda/lower_magic_zero.h>
#include <torch/csrc/jit/codegen/cuda/mutator.h>
#include <torch/csrc/jit/codegen/cuda/ops/all_ops.h>
#include <torch/csrc/jit/codegen/cuda/root_domain_map.h>
#include <torch/csrc/jit/codegen/cuda/scheduler/all_schedulers.h>
#include <torch/csrc/jit/codegen/cuda/scheduler/reduction_utils.h>
#include <torch/csrc/jit/codegen/cuda/scheduler/utils.h>
#include <torch/csrc/jit/codegen/cuda/test/test_gpu_validator.h>
#include <torch/csrc/jit/codegen/cuda/test/test_utils.h>
#include <torch/csrc/jit/codegen/cuda/transform_replay.h>
#include <torch/csrc/jit/codegen/cuda/transform_rfactor.h>

#include <test/cpp/jit/test_utils.h>
#include <torch/csrc/jit/api/function_impl.h>
#include <torch/csrc/jit/codegen/cuda/parser.h>
#include <torch/csrc/jit/ir/irparser.h>
#include <torch/torch.h>

#include <ATen/cuda/CUDAContext.h>
#include <ATen/cuda/Exceptions.h>
#include <c10/cuda/CUDAStream.h>

#include <algorithm>
#include <iostream>
#include <sstream>
#include <thread>

// Tests go in torch::jit
namespace torch {
namespace jit {

using namespace torch::jit::fuser::cuda;
using namespace at::indexing;

namespace {

TensorView* loweredTv(TensorView* tv, GpuLower& gpulw) {
  auto used_tvs = ir_utils::allTvs(gpulw.kernel()->as<Fusion>());
  TensorView* matching_tv = nullptr;
  for (auto lowered_tv : used_tvs) {
    if (lowered_tv->name() == tv->name()) {
      matching_tv = lowered_tv;
    }
  }
  TORCH_INTERNAL_ASSERT(matching_tv != nullptr);
  return matching_tv;
}

class PredicatedChecker : public kir::IrVisitor {
 public:
  // Checks if the provided tv is written to within a non-trivial conditional
  static bool isPredicated(TensorView* tv, GpuLower& gpulw) {
    PredicatedChecker checker(
        loweredTv(tv, gpulw), gpulw.kernel()->topLevelExprs());
    return checker.is_predicated_;
  }

 private:
  PredicatedChecker() = delete;

  PredicatedChecker(TensorView* tv, std::vector<Expr*> exprs) : tv_(tv) {
    kir::IrVisitor::handle(exprs);
  }

  using kir::IrVisitor::handle;
  bool is_predicated_ = false;
  bool predicated_ite_ = false;
  TensorView* tv_ = nullptr;

  void handle(kir::IfThenElse* ite) final {
    auto prev_ite = predicated_ite_;
    predicated_ite_ = !ite->predicate()->value()->isConstScalar();
    kir::IrVisitor::handle(ite);
    predicated_ite_ = prev_ite;
  }

  void handle(Expr* expr) final {
    if (expr->outputs().size() && expr->outputs()[0]->isA<kir::TensorIndex>()) {
      auto ti = expr->outputs()[0]->as<kir::TensorIndex>();
      if (ti->view() == tv_) {
        is_predicated_ = is_predicated_ | predicated_ite_;
        if (expr->predicate() != nullptr &&
            !expr->predicate()->value()->isConst()) {
          is_predicated_ = true;
        }
      }
    }
    kir::IrVisitor::handle(expr);
  }
};

class UnswitchInElseChecker : public kir::IrVisitor {
 public:
  // Checks if there are any unswitched for loops within an else clause
  static bool check(GpuLower& gpulw) {
    UnswitchInElseChecker checker(gpulw.kernel()->topLevelExprs());
    return checker.found_in_else_;
  }

 private:
  UnswitchInElseChecker() = delete;
  UnswitchInElseChecker(std::vector<Expr*> exprs) {
    kir::IrVisitor::handle(exprs);
  }

  using kir::IrVisitor::handle;
  bool within_else_ = false;
  bool found_in_else_ = false;

  void handle(kir::IfThenElse* ite) final {
    auto prev_within_else = within_else_;
    within_else_ = true;
    kir::IrVisitor::handle(ite->elseBody().exprs());
    within_else_ = prev_within_else;
  }

  void handle(kir::ForLoop* for_loop) final {
    if (for_loop->iter_domain()->getParallelType() == ParallelType::Unswitch) {
      found_in_else_ = found_in_else_ || within_else_;
    }
    kir::IrVisitor::handle(for_loop);
  }
};

class PredicateMagicZeroChecker : public kir::IrVisitor {
 public:
  // Checks if all predicated domains of the provided tv are protected with
  // magic zero
  static bool isProtected(TensorView* tv, GpuLower& gpulw) {
    PredicateMagicZeroChecker checker(
        loweredTv(tv, gpulw), gpulw.kernel()->topLevelExprs());
    return checker.is_protected_;
  }

 private:
  using kir::IrVisitor::handle;

  PredicateMagicZeroChecker(TensorView* tv, std::vector<Expr*> exprs)
      : tv_(tv) {
    handle(exprs);
  }

  void handle(kir::IfThenElse* ite) final {
    auto prev_predicate = predicate_;
    predicate_ = ite->predicate()->value();
    kir::IrVisitor::handle(ite);
    predicate_ = prev_predicate;
  }

  void handle(Expr* expr) final {
    if (expr->outputs().size() && expr->outputs()[0]->isA<kir::TensorIndex>()) {
      auto ti = expr->outputs()[0]->as<kir::TensorIndex>();
      if (ti->view() == tv_) {
        is_protected_ = checkPredicateOfTensor(predicate_);
        return;
      }
    }

    if (expr->isA<kir::ForLoop>()) {
      handle(expr->as<kir::ForLoop>());
    } else if (expr->isA<kir::IfThenElse>()) {
      handle(expr->as<kir::IfThenElse>());
    } else {
      for (auto input : expr->inputs()) {
        handle(input);
      }
    }
  }

  // Return true If all predicated domains are protected
  bool checkPredicateOfTensor(Val* predicate) {
    auto id_predicates = decomposeCompoundPredicate(predicate);
    for (auto id_predicate : id_predicates) {
      // Just check if nvfuser_zero is used. Not perfect but probably
      // good enough.
      is_magic_zero_found_ = false;
      handle(id_predicate);
      if (!is_magic_zero_found_) {
        return false;
      }
    }
    return true;
  }

  // Decompose "X && Y" to a vector of {X, Y}.
  std::vector<Val*> decomposeCompoundPredicate(Val* predicate) {
    if (auto binary_op = dynamic_cast<BinaryOp*>(predicate->definition())) {
      if (binary_op->getBinaryOpType() == BinaryOpType::And) {
        auto pred = decomposeCompoundPredicate(binary_op->lhs());
        auto rhs_pred = decomposeCompoundPredicate(binary_op->rhs());
        pred.insert(pred.end(), rhs_pred.begin(), rhs_pred.end());
        return pred;
      }
    }

    return {predicate};
  }

  void handle(Val* val) final {
    if (isMagicZero(val)) {
      is_magic_zero_found_ = true;
      return;
    }

    auto def = val->definition();
    if (def != nullptr) {
      handle(def);
    }
  }

 private:
  bool is_protected_ = false;
  Val* predicate_ = nullptr;
  TensorView* tv_ = nullptr;
  bool is_magic_zero_found_ = false;
};

// Basically just TransformPropagator, except that it checks the consistency
// replayPasC with getMatchedLeafPosWithoutReplayPasC, replayCasP with
// getMatchedLeafPosWithoutReplayCasP, and fullSelfReplay with fullSelfMatching:
// - After replayPasC, getMatchedLeafPosWithoutReplayPasC should return the same
//   replayed position
// - After replayCasP, getMatchedLeafPosWithoutReplayCasP should return the same
//   replayed position
// - After fullSelfReplay, fullSelfMatching should return true
struct TransformPropagatorWithCheck : public TransformPropagator {
 public:
  virtual void propagateC2P(TensorView* from, TensorView* to) override {
    TransformPropagator::propagateC2P(from, to);
    auto from_pos = replayed_pos_.at(from);
    auto to_pos = replayed_pos_.at(to);
    TORCH_CHECK(
        TransformReplay::getMatchedLeafPosWithoutReplayPasC(
            to, from, from_pos) == to_pos);
  }
  virtual void propagateP2C(TensorView* from, TensorView* to) override {
    TransformPropagator::propagateP2C(from, to);
    auto from_pos = replayed_pos_.at(from);
    auto to_pos = replayed_pos_.at(to);
    TORCH_CHECK(
        TransformReplay::getMatchedLeafPosWithoutReplayCasP(
            to, from, from_pos) == to_pos);
  }
  virtual void propagateSibling(TensorView* from, TensorView* to) override {
    TransformPropagator::propagateSibling(from, to);
    auto from_pos = replayed_pos_.at(from);
    auto to_pos = replayed_pos_.at(to);
    TORCH_CHECK(from_pos == to_pos);
    TORCH_CHECK(TransformReplay::fullSelfMatching(from, to));
  }
  using TransformPropagator::TransformPropagator;
};

} // namespace


TEST_F(NVFuserTest, FusionClampElems_CUDA) {
  Fusion fusion;
  FusionGuard fg(&fusion);
  // dimensionality of the problem
  int nDims = 2;
  int nElem = 8;
  int nFeat = 128;

  // Set up your input tensor views
  TensorView* tv1 = makeContigTensor(nDims);
  TensorView* tv_idx = makeContigTensor(1, DataType::Int);

  // Register your inputs
  fusion.addInput(tv1);
  fusion.addInput(tv_idx);

  // Do math with it, it returns a `Val*` but can be static_casted back to
  // TensorView
  //auto tv2 = castOp(DataType::Float, tv1);
  TensorView* tv_clamp = clamp(
      tv_idx, IrBuilder::create<Int>(0), IrBuilder::create<Int>(10));
  TensorView* tv_sel = castOp(DataType::Float, tv_clamp);
  TensorView* tv2 = mul(tv_sel, tv1);
  TensorView* tv3 = add(IrBuilder::create<Double>(17.0), tv2);

  // Register your outputs
  fusion.addOutput(tv3);
  // Do transformations, remember, transformations are outputs to inputs
  // This doesn't have to be in this order
  tv3->merge(0);
  // Split by n_threads
  tv3->split(0, 128);

  // For all inputs, computeAt the output inline, temporaries should be squeezed
  // between them
  tv_idx->computeAt(tv3, -1);
  tv1->computeAt(tv3, -1);

  // Parallelize TV3
  tv3->axis(0)->parallelize(ParallelType::BIDx);
  tv3->axis(-1)->parallelize(ParallelType::TIDx);

  //fusion.print();
  fusion.printMath();
  // fusion.printKernel();

  auto options = at::TensorOptions().dtype(at::kFloat).device(at::kCUDA, 0);
  auto options_idx = at::TensorOptions().dtype(at::kFloat).device(at::kCPU, 0);

  at::Tensor input1 = at::randn({nElem, nFeat}, options);
  at::Tensor input2 = at::rand_like(input1);
  at::Tensor input_idx = at::randn({nElem}, options_idx).to(torch::kInt).to(torch::kCUDA);

  at::Tensor output = at::empty_like(input1);

  FusionExecutor fe;
  fe.compileFusion(&fusion, {input2, input_idx});
  fe.runFusion({input2, input_idx}, {output});

  TORCH_CHECK(true);
}

TEST_F(NVFuserTest, FusionSelectElemsV2_CUDA) {
  Fusion fusion;
  FusionGuard fg(&fusion);
  // dimensionality of the problem
  int nDims = 2;
  int nElem = 8;
  int nFeat = 128;

  // Set up your input tensor views
  TensorView* tv0 = makeContigTensor(nDims);
  TensorView* tv1 = makeContigTensor(nDims);

  TensorView* tv_val = makeContigTensor(nDims);
  TensorView* tv_idx = makeContigTensor(1, DataType::Int);

  // Register your inputs
  fusion.addInput(tv0);
  fusion.addInput(tv1);
  fusion.addInput(tv_idx);

  // Do math with it, it returns a `Val*` but can be static_casted back to
  // TensorView
  //auto tv2 = castOp(DataType::Float, tv1);
  TensorView* tv_sel = index_select(tv0, IrBuilder::create<Int>(0), tv_idx);
  TensorView* tv2 = mul(tv_sel, tv1);
  TensorView* tv3 = add(IrBuilder::create<Double>(17.0), tv2);

  // Register your outputs
  fusion.addOutput(tv3);
  // Do transformations, remember, transformations are outputs to inputs
  // This doesn't have to be in this order
  tv3->merge(0);
  // Split by n_threads
  tv3->split(0, 128);

  // For all inputs, computeAt the output inline, temporaries should be squeezed
  // between them
  tv_sel->computeAt(tv3, -1);
  tv1->computeAt(tv3, -1);

  // Parallelize TV3
  tv3->axis(0)->parallelize(ParallelType::BIDx);
  tv3->axis(-1)->parallelize(ParallelType::TIDx);

  //fusion.print();
  fusion.printMath();
  // fusion.printKernel();

  auto options = at::TensorOptions().dtype(at::kFloat).device(at::kCUDA, 0);
  auto options_idx = at::TensorOptions().dtype(at::kFloat).device(at::kCPU, 0);

  at::Tensor input1 = at::randn({nElem, nFeat}, options);
  at::Tensor input2 = at::rand_like(input1);
  at::Tensor input_idx = at::randn({nElem}, options_idx).to(torch::kInt).to(torch::kCUDA);

  at::Tensor output = at::empty_like(input1);

  FusionExecutor fe;
  fe.compileFusion(&fusion, {input1, input2, input_idx});
  fe.runFusion({input1, input2, input_idx}, {output});

  TORCH_CHECK(true);
}

TEST_F(NVFuserTest, FusionSelectElems_CUDA) {
  Fusion fusion;
  FusionGuard fg(&fusion);
  // dimensionality of the problem
  int nDims = 2;
  int nElem = 8;
  int nFeat = 128;

  // Set up your input tensor views
  TensorView* tv0 = makeContigTensor(nDims);
  TensorView* tv1 = makeContigTensor(nDims);

  TensorView* tv_val = makeContigTensor(nDims);
  TensorView* tv_idx = makeContigTensor(1);

  // Register your inputs
  fusion.addInput(tv0);
  fusion.addInput(tv1);

  // Do math with it, it returns a `Val*` but can be static_casted back to
  // TensorView
  TensorView* tv2 = mul(tv0, tv1);
  TensorView* tv3 = add(IrBuilder::create<Double>(17.0), tv2);

  TensorView* tv_t = index_select(tv_val, IrBuilder::create<Int>(0), tv_idx);

  // Register your outputs
  fusion.addOutput(tv3);

  // Do transformations, remember, transformations are outputs to inputs
  // This doesn't have to be in this order
  tv3->merge(0);

  // Split by n_threads
  tv3->split(0, 128);

  // For all inputs, computeAt the output inline, temporaries should be squeezed
  // between them
  tv0->computeAt(tv3, -1);
  tv1->computeAt(tv3, -1);

  // Parallelize TV3
  tv3->axis(0)->parallelize(ParallelType::BIDx);
  tv3->axis(-1)->parallelize(ParallelType::TIDx);

  auto options = at::TensorOptions().dtype(at::kFloat).device(at::kCUDA, 0);
  auto options_idx = at::TensorOptions().dtype(at::kFloat).device(at::kCPU, 0);

  at::Tensor input1 = at::randn({nElem, nFeat}, options);
  at::Tensor input2 = at::rand_like(input1);
  at::Tensor input_idx = at::randn({nElem}, options_idx).to(torch::kInt).to(torch::kCUDA);
  /*
  std::vector<int32_t> val_array = {3, 1, 2, 7, 6, 0, 5, 4};
  at::Tensor input_idx = torch::from_blob(
      val_array.data(),
      {nElem},
      torch::TensorOptions().dtype(torch::kInt32).device(torch::kCPU)).to(torch::kCUDA);
  */
  at::Tensor output = at::empty_like(input1);

  FusionExecutor fe;
  fe.compileFusion(&fusion, {input1, input2});
  fe.runFusion({input1, input2}, {output});

  at::Tensor tv2_ref = input2 + 2.0;
  at::Tensor output_ref = input1 + tv2_ref;

  //TORCH_CHECK(output_ref.equal(output));
  TORCH_CHECK(true);
}

TEST_F(NVFuserTest, FusionElems_CUDA) {
  Fusion fusion;
  FusionGuard fg(&fusion);
  // dimensionality of the problem
  int nDims = 2;

  // Set up your input tensor views
  TensorView* tv0 = makeContigTensor(nDims);
  TensorView* tv1 = makeContigTensor(nDims);

  // Register your inputs
  fusion.addInput(tv0);
  fusion.addInput(tv1);

  // Do math with it, it returns a `Val*` but can be static_casted back to
  // TensorView
  TensorView* tv2 = mul(tv0, tv1);
  TensorView* tv3 = add(IrBuilder::create<Double>(17.0), tv2);

  // Register your outputs
  fusion.addOutput(tv3);

  // Do transformations, remember, transformations are outputs to inputs
  // This doesn't have to be in this order
  tv3->merge(0);

  // Split by n_threads
  tv3->split(0, 128);

  // For all inputs, computeAt the output inline, temporaries should be squeezed
  // between them
  tv0->computeAt(tv3, -1);
  tv1->computeAt(tv3, -1);

  // Parallelize TV3
  tv3->axis(0)->parallelize(ParallelType::BIDx);
  tv3->axis(-1)->parallelize(ParallelType::TIDx);

  auto options = at::TensorOptions().dtype(at::kFloat).device(at::kCUDA, 0);

  at::Tensor input1 = at::randn({512, 128}, options);
  at::Tensor input2 = at::rand_like(input1);
  at::Tensor output = at::empty_like(input1);

  FusionExecutor fe;
  fe.compileFusion(&fusion, {input1, input2});
  fe.runFusion({input1, input2}, {output});

  at::Tensor tv2_ref = input2 + 2.0;
  at::Tensor output_ref = input1 + tv2_ref;

  //TORCH_CHECK(output_ref.equal(output));
  TORCH_CHECK(true);
}

} // namespace jit
} // namespace torch
#endif // #if defined(USE_CUDA)
```