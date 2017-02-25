#!/bin/sh -e

# this version of install-libclapack.sh is used for building packages in CI environment.

#
# Debian 8
# Ubuntu 14.04
# Ubuntu 16.04
# Ubuntu 16.10
#

SUDO=$(which sudo || echo "")

$SUDO apt-get -y --no-install-recommends install lsb-release

if [ "$(lsb_release -is)" = "Ubuntu" ] && ([ "$(lsb_release -cs)" = "trusty" ] || [ "$(lsb_release -cs)" = "xenial" ]) ; then

    # clapack is not available in trusty, backporting it from 16.10

    echo "deb-src http://archive.ubuntu.com/ubuntu yakkety main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
    $SUDO apt-get update

    $SUDO apt-get -y --no-install-recommends install dpkg-dev debhelper cmake d-shlibs dh-exec chrpath gfortran python doxygen graphviz libgsl0-dev

    # Package          Source Package
    # libf2c2          libf2c2
    # libf2c2-dev      libf2c2
    # libblas-common   lapack
    # libcblas3        clapack
    # libclapack3      clapack
    # libclapack-dev   clapack

    mkdir -p libf2c2 && cd libf2c2
    apt-get source libf2c2
    for pkg in $(find * -maxdepth 0 -type d) ; do
        cd "$pkg"
        dpkg-buildpackage -us -uc -b
        cd ..

        cp libf2c2*.deb ..
        $SUDO dpkg -i libf2c2*.deb
    done
    cd ..

#    mkdir -p lapack && cd lapack
#    apt-get source lapack
#    for pkg in $(find * -maxdepth 0 -type d) ; do
#        cd "$pkg"
#        # patch debhelper dependency to be less strict
#        sed -i 's/9\.20160114~/9/' debian/control
#        sed -i 's/dh_strip --dbgsym-migration.*/dh_strip/' debian/rules
#        dpkg-buildpackage -us -uc -b
#        cd ..
#
#        cp libblas-common*.deb ..
#        $SUDO dpkg -i libblas-common*.deb
#    done
#    cd ..

    mkdir -p clapack && cd clapack
    apt-get source clapack
    for pkg in $(find * -maxdepth 0 -type d) ; do
        cd "$pkg"
        # skip dependecy on empty package
        sed -i 's/, libblas-common//' debian/control
        tee debian/rules << EOF
#!/usr/bin/make -f

export DEB_BUILD_HARDENING_FORMAT:=0
DPKG_EXPORT_BUILDFLAGS = 1

export DEB_BUILD_MAINT_OPTIONS=hardening=+bindnow

%:
	dh \$@ --buildsystem=cmake
EOF

        dpkg-buildpackage -us -uc -b
        cd ..

        cp libcblas3*.deb ..
        cp libclapack3*.deb ..
        cp libclapack-dev*.deb ..
        $SUDO dpkg -i libcblas3*.deb libclapack3*.deb libclapack-dev*.deb
    done
    cd ..

elif [ "$(lsb_release -is)" = "Debian" ] && [ "$(lsb_release -cs)" = "jessie" ] ; then

    # fetch packages from stretch repo for jessie, seems to work fine
    wget http://ftp.de.debian.org/debian/pool/main/l/lapack/libblas-common_3.7.0-1_amd64.deb
    wget http://ftp.de.debian.org/debian/pool/main/c/clapack/libcblas3_3.2.1+dfsg-1_amd64.deb
    wget http://ftp.de.debian.org/debian/pool/main/c/clapack/libclapack3_3.2.1+dfsg-1_amd64.deb
    wget http://ftp.de.debian.org/debian/pool/main/c/clapack/libclapack-dev_3.2.1+dfsg-1_amd64.deb

    $SUDO dpkg -i *.deb || $SUDO apt-get install -f -y

    exit $?
fi

echo "No special rules apply for your distribution, trying to install dependencies via apt-get..."

$SUDO apt-get install libclapack-dev libf2c2-dev libgsl0-dev

