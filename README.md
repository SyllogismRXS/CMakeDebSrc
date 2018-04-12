# CMakeDebSrc

Building debian binary packages is easy with CMake/CPack, but CMake/CPack lack
the ability to generate debian source packages that can be uploaded to
LaunchPad and other debian package building systems, such as Open Build
Service. This project is a collection of CMake functions to simplify building,
testing, and uploading debian source packages.

# Build CMakeDebSrc

    $ mkdir build && cd build
    $ cmake ..

At this point, your other CMake projects can find CMakeDebSrc project using
"find\_package(CMakeDebSrc)". However, this project does contain a valid "make
install" target, if required.

# Setup

## Install required packages

On Ubuntu 16.04, install the required packages:

    $ sudo apt-get install pbuilder ubuntu-dev-tools debootstrap

## Setup an Ubuntu Distribution pbuild Environment

Setup your .pbuilderrc file with the provided example:

    $ cp pbuilderrc ~/.pbuilderrc

Add keyrings for Ubuntu:

    $ sudo apt install ubuntu-keyring debian-archive-keyring

Add keyring for repos.rcn-ee.net

    $ wget -qO - http://repos.rcn-ee.net/ubuntu/conf/repos.rcn-ee.net.gpg.key | sudo apt-key add -

Create a pbuilder environment for xenial / amd64:

    $ sudo DIST=xenial ARCH=amd64 pbuilder \
        --create               \
        --distribution xenial  \
        --architecture amd64   \
        --basetgz /var/cache/pbuilder/xenial-amd64-base.tgz

This will create a tarball of the distribution in /var/cache/pbuilder. This
environment can be safely removed from your system with the "rm" command.

Create a pbuilder environment for xenial / armhf

    $ sudo dpkg --add-architecture armhf
    $ sudo apt-get update
    $ sudo apt-get install build-essential crossbuild-essential-armhf

    $ sudo apt-get install qemu-user-static
    $ sudo DIST=xenial ARCH=armhf pbuilder \
        --create               \
        --distribution xenial  \
        --architecture armhf   \
        --basetgz /var/cache/pbuilder/xenial-armhf-base.tgz

Create a pbuilder environment for xenial / arm64

    $ sudo dpkg --add-architecture arm64
    $ sudo apt-get update
    $ sudo apt-get install crossbuild-essential-arm64

    $ sudo apt-get install qemu-user-static
    $ sudo DIST=xenial ARCH=arm64 pbuilder \
        --create               \
        --distribution xenial  \
        --architecture arm64   \
        --basetgz /var/cache/pbuilder/xenial-arm64-base.tgz

Allow pbuilder to have access to the network during build-time:

    $ echo 'USENETWORK=yes' | sudo tee -a /etc/pbuilderrc

## pbuilder References
https://blog.packagecloud.io/eng/2015/05/18/building-deb-packages-with-pbuilder/
https://wiki.ubuntu.com/PbuilderHowto#Using_pbuilder-dist_to_manage_different_architectures_and_distro_releases
https://wiki.debian.org/PbuilderTricks
https://jodal.no/2015/03/08/building-arm-debs-with-pbuilder/
https://larry-price.com/blog/2016/09/27/clean-package-building-with-pbuilder/

# Setup your GPG Key

See [Using Passwords and Encryption Keys to manage OpenPGP keys](https://help.launchpad.net/YourAccount/ImportingYourPGPKey)

# Build the Example

    $ cd ./example
    $ mkdir build && cd build
    $ cmake .. -DPPA=ppa:kevin-demarco/cmake-project-template \
               -DGPG_KEY_ID=3951DA01

where the PPA and GPG\_KEY\_ID are correct for your system.

## Create a debian source package

    $ make pybind11-debuild

## Use pbuilder to perform a local test build of your source package

    $ make pybind11-local-test

## Upload the debian source package to LaunchPad

    $ make pybind11-upload-ppa

# Understanding the Example

In the example directory, there is a CMake project called "MyCoolProject" that
uses the "BuildDebSrcFromRepo" CMake function to generate a debian source
package from a git repository. Make sure you use the
"find_package(CMakeDebSrc)" cmake command to get access to the
"BuildDebSrcFromRepo" function. Every debian source package requires a debian
folder with at least the following files: changelog, control, copyright, and
rules. You will find the debian directory for the pybind11 package under
./example/packages/pybind11/debian. You can use these files as a starting point
for packaging your own project.

# Suggested Workflow

If you have a project where you have to build multiple packages from source, it
is suggested that you copy the "example" CMake project and add additional
directories under the "./example/packages" for each of your depedencies. You
will have to manually modify the files under the "debian" directory since these
files may vary greatly between projects. You can use git to track the debian
configuration files and use the CMake functions provided in this project to
locally test debian source package builds and upload them to LaunchPad.
