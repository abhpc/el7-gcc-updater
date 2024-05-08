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

# Check if the current user is root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

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
            display_usage
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
    echo -e "----------------------------------------------------------------------------------------------------------\n"
else
    # Install gmp 6.1.2
    rm -rf gmp-6.1.2.tar.xz
    echo "Downloading gmp-6.1.2.tar.xz ..."
    wget https://ftp.gnu.org/gnu/gmp/gmp-6.1.2.tar.xz --no-check-certificate &>/dev/null
    echo "Uncompress gmp-6.1.2.tar.xz ..."
    tar -xf gmp-6.1.2.tar.xz
    cd gmp-6.1.2
    echo "Configure gmp-6.1.2 ..."
    ./configure --prefix=$DES/gmp-6.1.2 1>/dev/null
    echo "Make and make install gmp-6.1.2 ..."
    make -j $JN 1>/dev/null && make install 1>/dev/null
    cd ..
    rm -rf gmp-6.1.2*
    echo "gmp-6.1.2 has been install in $DES/gmp-6.1.2 successfully."
    echo -e "----------------------------------------------------------------------------------------------------------\n"
fi

# Check if mpfr-3.1.6 is already installed
if [ -d "$DES/mpfr-3.1.6" ]; then
    echo "mpfr-3.1.6 is already installed in $DES. Skipping installation."
    echo -e "----------------------------------------------------------------------------------------------------------\n"
else
    # Install mpfr 3.1.6
    echo "Downloading mpfr-3.1.6.tar.gz ..."
    rm -rf mpfr-3.1.6.tar.gz
    wget https://ftp.gnu.org/gnu/mpfr/mpfr-3.1.6.tar.gz --no-check-certificate &>/dev/null
    echo "Uncompress mpfr-3.1.6.tar.gz ..."
    tar xvf mpfr-3.1.6.tar.gz 1>/dev/null
    cd mpfr-3.1.6
    echo "Configure mpfr-3.1.6 ..."
    ./configure --prefix=$DES/mpfr-3.1.6 --with-gmp=$DES/gmp-6.1.2 1>/dev/null
    echo "Make and make install mpfr-3.1.6 ... "
    make -j $JN 1>/dev/null && make install 1>/dev/null
    cd ..
    rm -rf mpfr-3.1.6*
    echo "mpfr-3.1.6 has been install in $DES/mpfr-3.1.6 successfully."
    echo -e "----------------------------------------------------------------------------------------------------------\n"
fi


# Check if mpc-1.0.3 is already installed
if [ -d "$DES/mpc-1.0.3" ]; then
    echo "mpc-1.0.3 is already installed in $DES. Skipping installation."
    echo -e "----------------------------------------------------------------------------------------------------------\n"
else
    # Install mpc 1.0.3
    echo "Download mpc-1.0.3.tar.gz ..."
    rm -rf mpc-1.0.3.tar.gz
    wget https://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz --no-check-certificate &>/dev/null
    echo "Uncompress mpc-1.0.3.tar.gz ..."
    tar xvf mpc-1.0.3.tar.gz 1>/dev/null
    cd mpc-1.0.3
    echo "Configure mpc-1.0.3 ..."
    ./configure --prefix=$DES/mpc-1.0.3 --with-gmp=$DES/gmp-6.1.2 --with-mpfr=$DES/mpfr-3.1.6 1>/dev/null
    echo "Make and make install mpc-1.0.3 ..."
    make -j $JN 1>/dev/null && make install 1>/dev/null
    cd ..
    rm -rf mpc-1.0.3*
    echo "mpc-1.0.3 has been install in $DES/mpc-1.0.3 successfully."
    echo -e "----------------------------------------------------------------------------------------------------------\n"
fi


# ld configure
echo "Update /etc/ld.so.conf ..."
echo "$DES/gmp-6.1.2/lib"  >> /etc/ld.so.conf
echo "$DES/mpfr-3.1.6/lib" >> /etc/ld.so.conf
echo "$DES/mpc-1.0.3/lib"  >> /etc/ld.so.conf
awk '!seen[$0]++' /etc/ld.so.conf > /etc/ld.so.conf.tmp
mv -f /etc/ld.so.conf.tmp /etc/ld.so.conf
ldconfig -v &> /dev/null

# Check if gcc is already installed
if [ -d "$DES/gcc-$GCC_VERS" ]; then
    echo "gcc-$GCC_VERS is already installed in $DES. Skipping installation."
    echo -e "----------------------------------------------------------------------------------------------------------\n"
else
    # Install GCC
    echo "Downloading gcc-$GCC_VERS.tar.xz ..."
    rm -rf gcc-$GCC_VERS.tar.xz
    wget https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERS/gcc-$GCC_VERS.tar.xz &>/dev/null
    echo "Uncompress gcc-$GCC_VERS.tar.xz ..."
    tar xvf gcc-$GCC_VERS.tar.xz 1>/dev/null
    cd gcc-$GCC_VERS
    echo "Configure gcc-$GCC_VERS ..."
    ./configure --enable-checking=release --enable-languages=c,c++,fortran --disable-multilib \
                                                --prefix=$DES/gcc-$GCC_VERS --with-gmp=$DES/gmp-6.1.2 \
                                                --with-mpfr=$DES/mpfr-3.1.6 --with-mpc=$DES/mpc-1.0.3 1>/dev/null
    echo "Make and make install gcc-$GCC_VERS ..."
    make -j $JN 1>/dev/null &&  make install 1>/dev/null
    cd ..
    rm -rf gcc-$GCC_VERS/ gcc-$GCC_VERS.tar.xz
    echo "gcc-$GCC_VERS has been install in $DES/gcc-$GCC_VERS successfully."
fi