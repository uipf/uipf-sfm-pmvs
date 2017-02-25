PMVS Module for UIPF-SfM
========================

Install
-------

Dependencies:

 - clapack

Install:

    apt-get install libclapack-dev libf2c2-dev
    
The above packages are not available on Debian 8 and Ubuntu 14.04, you can install them anyway with the following scripts.
Running `install-libclapack.sh` on Debian will load packages from Debian 9 which are compatible with Debian 8.
For Ubunu you can use `install-libclapack-ci.sh` which will create backport packages from Ubuntu 16.10. However it is generally recommended
and easier to install using the precompiled binaries.

cmake will patch and install pmvs. Patches are needed to compile it on a 64bit system.

Further dependencies:

    apt-get install libgsl0-dev