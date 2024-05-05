#! /bin/bash

GCC_VERS=$1
DES=$2
JN=$3

# Download gmp, mpfr and mpc

# Install gmp 6.1.2
rm -rf gmp-6.1.2.tar.xz
wget https://ftp.gnu.org/gnu/gmp/gmp-6.1.2.tar.xz --no-check-certificate
tar xvf gmp-6.1.2.tar.xz
cd gmp-6.1.2
./configure --prefix=$DES/gmp-6.1.2
make -j $JN && make install
cd ..

# Install mpfr 3.1.6
rm -rf mpfr-3.1.6.tar.gz
wget https://ftp.gnu.org/gnu/mpfr/mpfr-3.1.6.tar.gz --no-check-certificate
tar xvf mpfr-3.1.6.tar.gz
cd mpfr-3.1.6
./configure --prefix=$DES/mpfr-3.1.6 --with-gmp=$DES/gmp-6.1.2
make -j $JN && make install
cd ..

# Install mpc 1.0.3
rm -rf mpc-1.0.3.tar.gz
wget https://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz --no-check-certificate
tar xvf mpc-1.0.3.tar.gz
cd mpc-1.0.3
./configure --prefix=$DES/mpc-1.0.3 --with-gmp=$DES/gmp-6.1.2 --with-mpfr=$DES/mpfr-3.1.6
make -j $JN && make install
cd ..

# Clean gmp, mpc and mpfr files and directory
rm -rf gmp-6.1.2* mpc-1.0.3* mpfr-3.1.6*

# ld configure
echo "$DES/gmp-6.1.2/lib"  >> /etc/ld.so.conf
echo "$DES/mpfr-3.1.6/lib" >> /etc/ld.so.conf
echo "$DES/mpc-1.0.3/lib"  >> /etc/ld.so.conf
ldconfig -v

# Install GCC
rm -rf gcc-$GCC_VERS.tar.xz
wget https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERS/gcc-$GCC_VERS.tar.xz
tar xvf gcc-$GCC_VERS.tar.xz
cd gcc-$GCC_VERS
./configure --enable-checking=release --enable-languages=c,c++,fortran --disable-multilib \
                                                --prefix=$DES/gcc-$GCC_VERS --with-gmp=$DES/gmp-6.1.2 \
                                                --with-mpfr=$DES/mpfr-3.1.6 --with-mpc=$DES/mpc-1.0.3
make -j $JN
make install