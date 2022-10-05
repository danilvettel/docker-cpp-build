#!/bin/bash

echo "Hello"
### Move to the code directory
cd /code

### Build the code
g++ main.cxx -o /Output/Release.exe

### Handling different OSes
if [ -f /etc/redhat-release ]; then
    ### Move the generated code to Output directory
    mv /Output/Release.exe /Output/CentOS-6.exe
fi
if [ -f /etc/lsb-release ]; then
    ### Move the generated code to Output directory
    mv /Output/Release.exe /Output/Ubuntu.exe
fi
