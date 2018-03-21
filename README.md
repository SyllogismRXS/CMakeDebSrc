# cmake-deb-src

Building debian binary packages is easy with CMake/CPack, but CMake/CPack lack
the ability to generate debian source packages that can be uploaded to
LaunchPad and other debian package building systems, such as Open Build
Service. This project is a collection of CMake functions to simplify building,
testing, and uploading debian source packages.

# Setup

## Install required packages

On Ubuntu 16.04, install the required packages:

    $ sudo apt-get install pbuilder ubuntu-dev-tools

## Setup an Ubuntu Distribution pbuild Environment

    $ pbuilder create
    $ pbuilder-dist xenial create

Allow pbuilder to have access to the network during build-time:

    $ echo 'USENETWORK=yes' | sudo tee -a /etc/pbuilderrc
    
    
