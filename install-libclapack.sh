#!/bin/sh

PACKAGES=""
PACKAGES="$PACKAGES http://ftp.de.debian.org/debian/pool/main/c/clapack/libclapack-dev_3.2.1+dfsg-1_amd64.deb"
PACKAGES="$PACKAGES http://ftp.de.debian.org/debian/pool/main/c/clapack/libclapack3_3.2.1+dfsg-1_amd64.deb"
PACKAGES="$PACKAGES http://ftp.de.debian.org/debian/pool/main/c/clapack/libcblas3_3.2.1+dfsg-1_amd64.deb"
PACKAGES="$PACKAGES http://ftp.de.debian.org/debian/pool/main/l/lapack/libblas-common_3.7.0-1_amd64.deb"
#PACKAGES="$PACKAGES http://ftp.de.debian.org/debian/pool/main/libf/libf2c2/libf2c2-dev_20130926-2_amd64.deb"

sudo apt-get install libf2c2 libf2c2-dev

mkdir /tmp/libclapack
cd /tmp/libclapack

for p in $PACKAGES
do
	wget $p
done

sudo dpkg -i *.deb

rm *.deb
cd -


