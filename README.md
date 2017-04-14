PMVS Module for UIPF-SfM
========================

UIPF Sfm modules for [PMVS2](http://www.di.ens.fr/pmvs/).

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
    
    
License
-------

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the [GNU General Public License](LICENSE.md) for more details.

All files under the `pmvs-2` directory are a copy of PMVS by Yasutaka Furukawa and Jean Ponce from <http://www.di.ens.fr/pmvs/>, distributed under the GNU General Public License.
