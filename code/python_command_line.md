# Python interface option

REF:
https://docs.python.org/3/using/cmdline.html

``` python
python -c <command> # Execute the python code in command

python -m <module-name> # Search sys.path for the named module and execute its contents

python -V # Print the Python version number and exit

python -i test.py # Enter interactive mode after executing the script or the command
# 可以在报错/raise expectation时使用

python -u # Force the stdout and stderr streams to be unbuffered.
# 确保print后立即输出

```