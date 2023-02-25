# python pdb debugger

``` python 
python3 -m pdb myscript.py
```


## General
``` python
restart/run # Restart the debugged Python program
q(uit)  # Quit from the debugger

h   # list 
all the available commands
h c # print help about the c command

d   #Move the current frame count levels down in the stack trace
u 
```

## Break point
``` python
b   # list all breakpoints
b test.py:25 # set the breakpoint at one line

cl(ear) # clear all breaks
cl 1    # clear the No.1 break

disable 1 # disable the No.1 break
enable 1  # enable the No.1 break
```

## Code launch
``` python
s(tep) # Execute the current line, stop at the first possible occasion
n(ext) # Continue execution until the next line in the current function

unt(il) 20 # Continue execution to line 20
r(eturn)   # Continue execution until the current function returns.
c(ontinue) # Continue execution until a breakpoint is encountered.

l     # List source code for the current file. 
ll    # List all source code for the current function

a     # Print the argument list of the current function.
p x   # Print the value of x
whatis x # Print the type of x
source x # Print the source code of x

display x # Print x if it changed
undisplay x

retval # Print the return value for the last return of a function.
```