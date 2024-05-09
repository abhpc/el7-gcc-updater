#! /bin/bash

# Function to display usage information
display_usage() {
    echo "Usage: $0 des=<directory> [-o <modulefile>]"
    echo "Options:"
    echo "  des=<directory> Specify the gcc install directory"
    echo "  -o <modulefiler>     Specify the output modulefile"
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
    echo "This script should be better to run as root."
fi

# Check the number of arguments
if [ $# -eq 0 ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    display_usage
    exit 0
elif [ $# -lt 2 ]; then
    echo "Error: Invalid argument!"
    display_usage
    exit 1
fi

# Parse the arguments
for ((i=1; i<=$#; i++)); do
    arg="${!i}"
    case $arg in
        des=*)
            DES="${arg#*=}"
            ;;
        -o)
            ((i++))
            MF="${!i}"
            ;;
        *)
            echo "Error: Invalid argument!"
            display_usage
            exit 1
            ;;
    esac
done

# Print the arguments
echo "GCC install directory: $DES"
echo "Output modulefile: $MF"

# Prompt for confirmation
prompt_confirmation
echo "Continuing..."

# Check if the $DES/lib64 directory exists
if [ ! -d "$DES/lib64" ]; then
    echo "gcc lib64 directory does not exist"
    exit 1
fi

# Check if the $DES/bin directory exists
if [ ! -d "$DES/bin" ]; then
    echo "gcc bin directory does not exist"
    exit 1
fi

# Check if the $DES/share/man directory exists
if [ ! -d "$DES/share/man" ]; then
    echo "gcc share/man directory does not exist"
    exit 1
fi

cat << EOF > $MF
#%Module 1.0
conflict        gcc
set             DES         $DES
prepend-path    PATH            \$DES/bin
prepend-path    LD_LIBRARY_PATH \$DES/lib64
prepend-path    LIBRARY_PATH    \$DES/lib64
prepend-path    MANPATH         \$DES/share/man
EOF
echo -e "----------------------------------------------------------------------------------------------------------"
echo "Generating enviroment modulefile for gcc (install directory: $DES) ... Done!"
echo -e "----------------------------------------------------------------------------------------------------------\n"