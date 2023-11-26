# pytorch profile with tensorboard

ref: [PyTorch Profiler With TensorBoard — PyTorch Tutorials 1.13.1+cu117 documentation](https://pytorch.org/tutorials/intermediate/tensorboard_profiler_tutorial.html)

How to install && run
``` python
pip install tensorboard
pip install torch_tb_profiler
tensorboard --logdir=./log
```

How to use

``` python
with torch.profiler.profile(
        schedule=torch.profiler.schedule(wait=5, warmup=1, active=1, repeat=1),
        on_trace_ready=torch.profiler.tensorboard_trace_handler(
            f"./log/tensor_board/"
        ),
        record_shapes=True,
        profile_memory=True,
        with_stack=True,
    ) as prof:
        for i, (batched_g) in enumerate(train_dataloader):
            batched_g = batched_g.to(dev)
            logits, elapsed_time = model(params, batched_g.ndata["feat"])
```
