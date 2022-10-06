# Cross-Platform C++ Builds using Docker

## TLDR

```bash
 USER_ID=$(id -u) GROUP_ID=$(id -g) docker-compose up build
```

---

1. One of the biggest pain points of C++ is just how customisable everything is
2. So a solution designed must
    1. Support different build systems. (Make, CMake, Some Custom IDE nonsense)
    2. Support adding different dependencies while keeping the same Dockerfile (for your sake)
    3. For example, an UI based project might want GTK or Qt
3. So the design needs to generalise over everything here

## Supported OSes
1. CentOS 6
    1. Here as you would see, we are using our own custom fixed version of the  
    CentOS Dockerfile because it is EOL
2. Ubuntu

---

## How it all works?

1. Extra Dependencies  
    Extra dependencies which can be obtained over the network are supposed to be added to _deps-install.sh_

    A sample deps-install for a team which wants Boost, Python, Curl and Wget

    So for CentOS 6 you need to modify the file in question and add  
    [deps-install.sh](deps-install.sh)
    ```bash
    yum install -y curl wget boost python-devel
    ```

    After modifying deps-install.sh, remember to rebuild your images to obtain the advantages of the new configuration.

    This is done only one time usually. It is not recommended to regularly make changes here without a focus on stability. Because this could be potentially very time consuming.

2. Different Build Systems
    1. I use Makefiles
    2. I use CMake
    3. I use Meson
    4. What is Build System?????
    And on and on and on

    For all such approaches, which we would need to support, the design depends on you writing a custom script for the same.

    For example, here we have a custom script by the name of [build.sh](code/build.sh)

    It looks like

    ```bash
    #!/bin/bash

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
    ```

    1. A CMake script would look radically different for example

    2. For Makefiles, you probably want to run make clean and make all commands for example

    3. For Custom scripts, you could add the calling here.

    Given the focus on customisability, as you would notice in our YAML, we also let you choose:-

    1. The Path of the Build Script
    2. The Name of the Build Script
    
    This way, the entire requisite decision making rests solely upon you the user :-P

    But how do you do this???

    ```yaml
    build:
      # Directory where to find the Docker file
      context: .
      dockerfile: Dockerfile
      # The Multi Stage Build Stage to use
      ## Using Ubuntu
      # target: ubuntu-builder
      ## Using CentOS 6
      target: centos-6-builder
     # The Folders to share
    entrypoint: ["/buildtools/build.sh"]
    volumes:
      # RO indicates that we are mounting as read only
      # Which in Docker means writing here would lead to an error
      - ./code:/code:ro
      # Just because they are at the same source path
      # Does not mean they both need to be ro
      - ./code:/buildtools:ro
      # If not ro, use z which tells Docker that this
      # mount is writable and it belongs to the host
      # And is potentially being used for other purposes
      # Not doing this can lead to errors
      - ./output:/Output:z
    ```

    As you can see

    1. Entrypoint names this build script to be called and its path
    2. We use volumes to separate paths and their concerns
    3. Each volume/path maps to its own logical path irrespective of the fact that buildtools and code point to the same directory 
    4. This helps us write cleaner build.sh scripts
    5. The output folder is present separately as a way to showcase our separation of concerns.
    6. My script assumes code is present in /code
    7. My script maps output to /Output
    8. My script is assumed to be present at /buildtools/build.sh
    9. This way everything is clean and separated


## Recommendations

1. Remember to separate your concerns  
    This can be done by harnessing the power of Docker Volumes as I have done above
2. Use simple and clean scripts and leverage your existing build systems.  
If separating concerns, remember to move the changes to the Output directory.
3. Remember that if you map your Output folder to /Output, then you must also in your build script move your output there
4. Remember to use the ":z" which I have used in the volume above if the volume can be modified.  
Use :ro if the volume is to be mounted as read only  
This is an indicator to Docker that this is a shared Mount Point. Otherwise you could have access control issues.
5. Test multiple times. ABI breaks and ABI incompatibility is a thing. libstdc++ has broken ABI multiple times over the years which is a major C++ dependency for example.
6. All your dependencies must support the respective OS/Configuration you have set using deps-install.sh
7. If a library you have manually added to /Library volume mount (separation of concerns), then ensure it was built with the exact image we are currently using. Otherwise, with differences in time, if any packages have ABI breaks, we could have issues at deployment and runs

## NO DOCKER. It runs as ROOT

False actually.

Thanks to 

```yaml
    # Run this compose by ensuring user and group id were set properly
    # Using
    #   USER_ID=$(id -u) 
    #   GROUP_ID=$(id -g)
    # Before you run this
    # This ensures that the build runs as our current user
    # And not as root which is default
    user: "${USER_ID}:${GROUP_ID}"
```

All you have to do is call it as

```bash
 USER_ID=$(id -u) GROUP_ID=$(id -g) docker-compose up build
```

Probably better off making this into a script

### Note, if you have changed deps-install.sh, call

```bash
 USER_ID=$(id -u) GROUP_ID=$(id -g) docker-compose up --build build
```
This will rebuild the image in question