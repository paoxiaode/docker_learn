# Bash cheat sheet

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