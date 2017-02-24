#!/bin/sh -e

# this version of install-libclapack.sh is used for building packages in CI environment.

which sudo || apt-get -y install sudo

APTINSTALL=
if apt-cache pkgnames |grep libclapack-dev ; then
    APTINSTALL="${APTINSTALL} libclapack3"
else
    if [ "$(lsb_release -is)" = "Ubuntu" ] ; then
        wget  http://de.archive.ubuntu.com/ubuntu/pool/universe/c/clapack/libclapack3_3.2.1+dfsg-1_amd64.deb
    else
        wget  http://ftp.de.debian.org/debian/pool/main/c/clapack/libclapack3_3.2.1+dfsg-1_amd64.deb
    fi
fi

if apt-cache pkgnames |grep libclapack-dev ; then
    APTINSTALL="${APTINSTALL} libclapack-dev"
else
    if [ "$(lsb_release -is)" = "Ubuntu" ] ; then
        wget  http://de.archive.ubuntu.com/ubuntu/pool/universe/c/clapack/libclapack-dev_3.2.1+dfsg-1_amd64.deb
    else
        wget http://ftp.de.debian.org/debian/pool/main/c/clapack/libclapack-dev_3.2.1+dfsg-1_amd64.deb
    fi
fi

if apt-cache pkgnames |grep libcblas3 ; then
    APTINSTALL="${APTINSTALL} libcblas3"
else
    if [ "$(lsb_release -is)" = "Ubuntu" ] ; then
        wget http://de.archive.ubuntu.com/ubuntu/pool/universe/c/clapack/libcblas3_3.2.1+dfsg-1_amd64.deb
    else
        wget http://ftp.de.debian.org/debian/pool/main/c/clapack/libcblas3_3.2.1+dfsg-1_amd64.deb
    fi
fi

if apt-cache pkgnames |grep libblas-common ; then
    APTINSTALL="${APTINSTALL} libblas-common"
else
    if [ "$(lsb_release -is)" = "Ubuntu" ] ; then
        wget http://de.archive.ubuntu.com/ubuntu/pool/main/l/lapack/libblas-common_3.6.0-2ubuntu2_amd64.deb
    else
        wget http://ftp.de.debian.org/debian/pool/main/l/lapack/libblas-common_3.7.0-1_amd64.deb
    fi
fi

sudo apt-get -y --no-install-recommends install $APTINSTALL libf2c2 libf2c2-dev libgsl0-dev

ls *.deb && sudo dpkg -i *.deb || echo "ok"
