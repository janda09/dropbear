#!/bin/sh

if [ ! -z $CROSS_COMP ] && [ -z `command -v $CROSS_COMP-gcc` ]; then
	unset CROSS_COMP
fi

wget https://raw.githubusercontent.com/janda09/myfiles/main/zlib-1.2.11.tar.gz
tar xvzf zlib-1.2.11.tar.gz
mkdir zlib_compiled
cd zlib-1.2.11
./configure --prefix=../zlib_compiled
if [ ! -z $CROSS_COMP ]; then
	sed -i 's/gcc/$(CROSS_COMP)-gcc/g' Makefile
	sed -i 's/AR=ar/AR=$(CROSS_COMP)-ar/g' Makefile
fi
make && make install
cd ..	
wget https://raw.githubusercontent.com/janda09/myfiles/main/DROPBEAR_2019.78.tar.gz
tar xvzf DROPBEAR_2019.78.tar.gz
patch -p0 < patch.patch
cd DROPBEAR_2019.78
autoconf && autoheader

if [ ! -z $CROSS_COMP ]; then
	./configure --host="$CROSS_COMP" --disable-lastlog --disable-utmp --disable-utmpx --disable-wtmp --disable-wtmpx --disable-shadow --disable-syslog --enable-static --with-zlib=`realpath ../zlib_compiled`
else
	./configure --disable-lastlog --disable-utmp --disable-utmpx --disable-wtmp --disable-wtmpx --disable-shadow --disable-syslog --enable-static --with-zlib=`realpath ../zlib_compiled`
fi
make STATIC=1 MULTI=1 PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp"
if [ ! -z $CROSS_COMP ]; then
	$CROSS_COMP-strip -s dropbearmulti
else
	strip -s dropbearmulti
fi
cp dropbearmulti ../
