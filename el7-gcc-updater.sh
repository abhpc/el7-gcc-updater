#! /bin/bash

# Function to display usage information
display_usage() {
    echo "Usage: $0 gcc=<version> des=<directory> [-j <number>]"
    echo "Options:"
    echo "  gcc=<version>   Specify the GCC version"
    echo "  des=<directory> Specify the install directory"
    echo "  -j <number>     Specify the number of compiling threads"
}

# Function to prompt for confirmation
prompt_confirmation() {
    read -t 15 -p "You have 15 seconds to confirm the information or program be automatically exit. Please confirm (y/n): " choice
    case $choice in
        y|Y)
            ;;
        *)
            echo "Exiting..."
            exit 0
            ;;
    esac
}

# Check the number of arguments
if [ $# -eq 0 ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    display_usage
    exit 0
elif [ $# -lt 3 ]; then
    echo "Error: Invalid argument!"
    display_usage
    exit 1
fi

# Parse the arguments
for ((i=1; i<=$#; i++)); do
    arg="${!i}"
    case $arg in
        gcc=*)
            GCC_VERS="${arg#*=}"
            ;;
        des=*)
            DES="${arg#*=}"
            ;;
        -j)
            ((i++))
            JN="${!i}"
            ;;
        *)
            echo "Error: Invalid argument!"
            exit 1
            ;;
    esac
done

# Print the arguments
echo "GCC_VERS=$GCC_VERS"
echo "DES=$DES"
echo "JN=$JN"

# Prompt for confirmation
prompt_confirmation
echo "Continuing..."


# Check if gmp-6.1.2 is already installed
if [ -d "$DES/gmp-6.1.2" ]; then
    echo "gmp-6.1.2 is already installed in $DES. Skipping installation."
else
    # Install gmp 6.1.2
    rm -rf gmp-6.1.2.tar.xz
    wget https://ftp.gnu.org/gnu/gmp/gmp-6.1.2.tar.xz --no-check-certificate
    tar -xf gmp-6.1.2.tar.xz
    cd gmp-6.1.2
    ./configure --prefix=$DES/gmp-6.1.2 &>/dev/null
    make -j $JN &>/dev/null && make install &>/dev/null
    cd ..
fi

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