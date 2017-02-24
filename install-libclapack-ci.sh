#!/bin/sh

# this version of install-libclapack.sh is used for building packages in CI environment.

APTINSTALL=
if apt-cache pkgnames |grep libclapack-dev ; then
    APTINSTALL="${APTINSTALL} libclapack-dev"
else
    wget http://ftp.de.debian.org/debian/pool/main/c/clapack/libclapack-dev_3.2.1+dfsg-1_amd64.deb
fi

if apt-cache pkgnames |grep libcblas3 ; then
    APTINSTALL="${APTINSTALL} libcblas3"
else
    wget http://ftp.de.debian.org/debian/pool/main/c/clapack/libcblas3_3.2.1+dfsg-1_amd64.deb
fi

if apt-cache pkgnames |grep libblas-common ; then
    APTINSTALL="${APTINSTALL} libblas-common"
else
    wget http://ftp.de.debian.org/debian/pool/main/l/lapack/libblas-common_3.7.0-1_amd64.deb
fi

apt-get -y --no-install-recommends install $APTINSTALL libf2c2 libf2c2-dev libgsl0-dev

ls *.deb && dpkg -i *.deb || echo "ok"
