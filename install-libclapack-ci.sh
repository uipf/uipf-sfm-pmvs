#!/bin/sh

# this version of install-libclapack.sh is used for building packages in CI environment.

PACKAGES=""
PACKAGES="$PACKAGES http://ftp.de.debian.org/debian/pool/main/c/clapack/libclapack-dev_3.2.1+dfsg-1_amd64.deb"
PACKAGES="$PACKAGES http://ftp.de.debian.org/debian/pool/main/c/clapack/libclapack3_3.2.1+dfsg-1_amd64.deb"
PACKAGES="$PACKAGES http://ftp.de.debian.org/debian/pool/main/c/clapack/libcblas3_3.2.1+dfsg-1_amd64.deb"
PACKAGES="$PACKAGES http://ftp.de.debian.org/debian/pool/main/l/lapack/libblas-common_3.7.0-1_amd64.deb"
#PACKAGES="$PACKAGES http://ftp.de.debian.org/debian/pool/main/libf/libf2c2/libf2c2-dev_20130926-2_amd64.deb"

apt-get -y install libf2c2 libf2c2-dev

for p in $PACKAGES
do
	wget $p
done

dpkg -i *.deb
