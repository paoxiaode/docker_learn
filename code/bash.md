# Bash cheat sheet
  - [Bash cheat sheet](#bash-cheat-sheet)
  - [Reference](#reference)
  - [Basic](#basic)
  - [Conditional statement](#conditional-statement)
  - [Loop](#loop)
  - [Function](#function)
  - [Array](#array)
  - [Example](#example)
  - [文本替换](#文本替换)
## Reference
https://devhints.io/bash

## Basic
``` bash
# Single line comment
:'
This is a
multi line
comment
'
$1 $2 $3 # 传入bash脚本的参数
$# #传入参数的数量
"$var" '$var' #单双引号不同，被单引号括起来的字符都是普通字符
```

## Conditional statement
``` bash
if then fi
if then else fi
if then elif else fi	

#!/bin/bash

if [ $1 -eq $2 ]; then
    echo "they are equal"
else
    echo "they are NOT equal"
fi
```

## Loop
``` bash
# range
for i in {1..5}; do
    echo "Welcome $i"
done

for i in {5..50..5}; do
    echo "Welcome $i"
done

# C-like for loop
for ((i = 0 ; i < 100 ; i++)); do
  echo $i
done

# Forever
while true; do
  ···
done

# Read lines
cat file.txt | while read line; do
  echo $line
done
```

## Function
``` bash
# Define
myfunc() {
    echo "hello $1"
}
myfunc "John"

# Return
myfunc() {
    local myresult='some value'
    echo $myresult
}
result="$(myfunc)"

# Raise error
myfunc() {
  return 1
}
if myfunc; then
  echo "success"
else
  echo "failure"
fi
```

## Array
``` bash
# Define
Fruits=('Apple' 'Banana' 'Orange')

# Operation
Fruits=("${Fruits[@]}" "Watermelon")    # Push
Fruits+=('Watermelon')                  # Also Push
Fruits=( ${Fruits[@]/Ap*/} )            # Remove by regex match
unset Fruits[2]                         # Remove one item
Fruits=("${Fruits[@]}")                 # Duplicate
Fruits=("${Fruits[@]}" "${Veggies[@]}") # Concatenate
lines=(`cat "logfile"`)                 # Read from file

# Work
echo ${Fruits[0]}           # Element #0
echo ${Fruits[-1]}          # Last element
echo ${Fruits[@]}           # All elements, space-separated
echo ${#Fruits[@]}          # Number of elements
echo ${#Fruits}             # String length of the 1st element
echo ${#Fruits[3]}          # String length of the Nth element
echo ${Fruits[@]:3:2}       # Range (from position 3, length 2)
echo ${!Fruits[@]}          # Keys of all elements, space-separated

# Loop
for i in "${arrayName[@]}"; do
  echo $i
done
```

## Example
``` bash
# get the current time
date=$(date +%Y%m%d-%H%M%S) 

# switch
if [ "$1" == "1" ]; then

fi
```

## 文本替换

ref: [sed命令](https://www.runoob.com/linux/linux-comm-sed.html)

`^`  锚定行的开始 如：/^sed/匹配所有以sed开头的行。 

`$ ` 锚定行的结束 如：/sed$/匹配所有以sed结尾的行。 

`.`  匹配一个非换行符的字符 如：/s.d/匹配s后接一个任意字符，然后是d。 
`* ` 匹配零或多个字符 如：/*sed/匹配所有模板是一个或多个空格后紧跟sed的行。

`[]` 匹配一个指定范围内的字符，如/[Ss]ed/匹配sed和Sed。 

`[^]`　匹配一个不在指定范围内的字符，如：/[^A-RT-Z]ed/匹配不包含A-R和T-Z的一个字母开头，紧跟ed的行。

`\(..\) `保存匹配的字符，如s/\(love\)able/\1rs，loveable被替换成lovers。

`&` 保存搜索字符用来替换其他字符，如s/love/**&**/，love这成**love**。 

`\<` 锚定单词的开始，如:/\<love/匹配包含以love开头的单词的行。 
`\>`锚定单词的结束，如/love\>/匹配包含以love结尾的单词的行。

`x\{m\}`重复字符x，m次，如：/o\{5\}/匹配包含5个o的行。 

`x\{m,\}`重复字符x,至少m次，如：/o\{5,\}/匹配至少有5个o的行。

`x\{m,n\}`重复字符x，至少m次，不多于n次，如：/o\{5,10\}/匹配5--10个o的行。
``` bash
# sed inst
sed 's/要被取代的字串/新的字串/g'
-r # use regular expression
-i # edit files in place

# eg
# 匹配第一个[]
sed -r -i 's/^\[[^\[]*\] //g' file
```