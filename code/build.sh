#!/bin/bash

echo "Hello"
### Move to the code directory
cd /code

### Build the code
g++ main.cxx


### Handling different OSes
if [  -n "$(uname -a | grep Ubuntu)" ]; then
    ### Move the generated code to Output directory
    mv a.out /Output/Ubuntu.exe
else
    ### Move the generated code to Output directory
    mv a.out /Output/CentOS-6.exe
fi  
