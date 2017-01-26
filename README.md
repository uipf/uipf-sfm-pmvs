PMVS Module for UIPF-SfM
========================

Install
-------

Dependencies:

 - clapack

Install:

    apt-get install libclapack-dev libf2c2-dev
    
The above packages are not available on Debian 8, you can install them anyway
by running `sudo install-libclapack.sh`. This will load packages from Debian 9 which are compatible with Debian 8.

cmake will patch and install pmvs. Patches are needed to compile it on a 64bit system.