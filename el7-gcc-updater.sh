#! /bin/bash
export SOFT_SERV="http://xxx"
DES="/opt/devt"
JN="20"

# Downlaod gcc 7.5.0, 9.5.0 and 13.1.0
wget $SOFT_SERV/gcc-7.5.0.tar.xz --no-check-certificate
wget $SOFT_SERV/gcc-9.5.0.tar.xz --no-check-certificate
wget $SOFT_SERV/gcc-13.1.0.tar.xz --no-check-certificate

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

# Clean gmp, mpc and mpfr files
rm -rf gmp-6.1.2 mpc-1.0.3 mpfr-3.1.6

# ld configure
echo "$DES/gmp-6.1.2/lib"  >> /etc/ld.so.conf
echo "$DES/mpfr-3.1.6/lib" >> /etc/ld.so.conf
echo "$DES/mpc-1.0.3/lib"  >> /etc/ld.so.conf
ldconfig -v

# Install GCC 7.5.0
export GCC_VERS="7.5.0"
tar xvf gcc-$GCC_VERS.tar.xz
cd gcc-$GCC_VERS
./configure --enable-checking=release --enable-languages=c,c++,fortran --disable-multilib \
                                                --prefix=$DES/gcc-$GCC_VERS --with-gmp=$DES/gmp-6.1.2 \
                                                --with-mpfr=$DES/mpfr-3.1.6 --with-mpc=$DES/mpc-1.0.3
make -j $JN
make install