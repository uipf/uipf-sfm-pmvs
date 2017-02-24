#!/bin/sh -e

# this version of install-libclapack.sh is used for building packages in CI environment.

which sudo || apt-get -y install sudo

APTINSTALL=
PBUILDER=
if apt-cache pkgnames |grep libclapack-dev ; then
    APTINSTALL="${APTINSTALL} libclapack3"
else
    if [ "$(lsb_release -is)" = "Ubuntu" ] ; then
        PBUILDER="${PBUILDER} libclapack3"
    else
        wget  http://ftp.de.debian.org/debian/pool/main/c/clapack/libclapack3_3.2.1+dfsg-1_amd64.deb
    fi
fi

if apt-cache pkgnames |grep libclapack-dev ; then
    APTINSTALL="${APTINSTALL} libclapack-dev"
else
    if [ "$(lsb_release -is)" = "Ubuntu" ] ; then
        PBUILDER="${PBUILDER} libclapack-dev"
    else
        wget http://ftp.de.debian.org/debian/pool/main/c/clapack/libclapack-dev_3.2.1+dfsg-1_amd64.deb
    fi
fi

if apt-cache pkgnames |grep libcblas3 ; then
    APTINSTALL="${APTINSTALL} libcblas3"
else
    if [ "$(lsb_release -is)" = "Ubuntu" ] ; then
        PBUILDER="${PBUILDER} libcblas3"
    else
        wget http://ftp.de.debian.org/debian/pool/main/c/clapack/libcblas3_3.2.1+dfsg-1_amd64.deb
    fi
fi

if apt-cache pkgnames |grep libblas-common ; then
    APTINSTALL="${APTINSTALL} libblas-common"
else
    if [ "$(lsb_release -is)" = "Ubuntu" ] ; then
        PBUILDER="${PBUILDER} libblas-common"
    else
        wget http://ftp.de.debian.org/debian/pool/main/l/lapack/libblas-common_3.7.0-1_amd64.deb
    fi
fi

sudo apt-get -y --no-install-recommends install $APTINSTALL libf2c2 libf2c2-dev libgsl0-dev

if [ "$PBUILDER" != "" ] ; then

    echo "deb-src http://archive.ubuntu.com/ubuntu $(lsb_release -cs) main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
    sudo apt-get update
    apt-get source $PBUILDER
    sudo apt-get install pbuilder debootstrap devscripts
    sudo pbuilder create --debootstrapopts --variant=buildd
    sudo pbuilder build *.dsc
    cp /var/cache/pbuilder/result/*.deb .

fi

ls *.deb && sudo dpkg -i *.deb || echo "ok"
