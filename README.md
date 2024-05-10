# el7-gcc-updater




## Introduction
```el7-gcc-updater``` is a shell script designed to assist root users in building various versions of gcc on CentOS 7.

## System requirement
Before run this script, please install necessary development tools:
```bash
yum install epel-release -y
yum groupinstall "Development Tools" -y
yum install texinfo -y
```

## GCC updater usage
```bash
./el7-gcc-updater.sh gcc=<version> des=<directory> [-j <number>]
Options:
  gcc=<version>   Specify the GCC version
  des=<directory> Specify the install directory
  -j <number>     Specify the number of compiling threads
```

## Generate related environment modulefile
```bash
./gen-modulefile.sh des=<directory> [-o <modulefile>]
Options:
  des=<directory> Specify the gcc install directory
  -o <modulefiler>     Specify the output modulefile
```

[def]: #2-质心曲线
[def2]: #13-paraview后处理