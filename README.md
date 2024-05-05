# el7-gcc-updater

```el7-gcc-updater``` is a shell script designed to assist root users in building various versions of gcc on CentOS 7.

Usage: 
```bash
./el7-gcc-updater.sh gcc=<version> des=<directory> [-j <number>]
Options:
  gcc=<version>   Specify the GCC version
  des=<directory> Specify the install directory
  -j <number>     Specify the number of compiling threads
```