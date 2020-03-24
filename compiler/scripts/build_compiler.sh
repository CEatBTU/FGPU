#!/bin/bash

###############################################################################
################### Set up directories and variables ##########################
###############################################################################

N_THREADS=5               # number of threads for compilation

HOME_DIR="/llvm"
DOWNLOAD_DIR="/tmp"

COMPILE_STRATEGY="Debug"  # set at "Release" for shorter compilation times. Set to "Debug" for debugging your LLVM code.

LLVM_SRC_NAME="llvm-3.7.1"
CLANG_SRC_NAME="cfe-3.7.1"

LLVM_SRC_DIR="${HOME_DIR}/${LLVM_SRC_NAME}.src"
LLVM_BUILD_DIR="${HOME_DIR}/${LLVM_SRC_NAME}.build"
LLVM_FGPU_SRC_DIR="${LLVM_SRC_DIR}.fgpu"

if [ -d $DOWNLOAD_DIR ]; then
  cd $DOWNLOAD_DIR
else
  echo "The given download dirctory ("$DOWNLOAD_DIR") does not exist or it is not a directory!"
  exit
fi

# download llvm-3.7.1 if not already done
if [ ! -e $LLVM_SRC_NAME".src.tar.xz" ]; then
  echo "Downloading LLVM!"
  wget "http://releases.llvm.org/3.7.1/"$LLVM_SRC_NAME".src.tar.xz"
  a=$?
  if [ $a != 0 ]; then
    echo "Downloaing llvm failed (exit code = "$a")!"
    exit $a
  fi
else
  echo $LLVM_SRC_NAME".src.tar.xz (llvm source code) already found in "$DOWNLOAD_DIR", no need for download!"
fi

# download clang if not already done
if [ ! -e $CLANG_SRC_NAME".src.tar.xz" ]; then
  wget "http://releases.llvm.org/3.7.1/"$CLANG_SRC_NAME".src.tar.xz"
  a=$?
  if [ $a != 0 ]; then
    echo "Downloaing clang failed (exit code = "$a")!"
    exit $a
  fi
else
  echo $CLANG_SRC_NAME"src..tar.xz (clang source code) already found in "$DOWNLOAD_DIR", no need for download!"
fi

if [ -d ${HOME_DIR} ]; then
    mkdir -p ${HOME_DIR}
    echo "Initializing the directory ${HOME_DIR}"
fi
cd ${HOME_DIR}
echo "CDing into tho ${HOME_DIR}"

echo "Attempting to delete old LLVM source files!"
rm -rf $LLVM_SRC_DIR
a=$?
if [ $a != 0 ]; then
  echo "Delete old LLVM source files failed (exit code = "$a")!"
  exit $a
fi

echo "Extracting LLVM source files!"
tar xvf ${DOWNLOAD_DIR}/$LLVM_SRC_NAME.src.tar.xz
a=$?
if [ $a != 0 ]; then
  echo "Extracting LLVM failed (exit code = "$a")!"
  exit $a
fi

echo "Extracting clang source files!"
tar xvf ${DOWNLOAD_DIR}/$CLANG_SRC_NAME.src.tar.xz -C $HOME_DIR"/"$LLVM_SRC_NAME".src/tools"
a=$?
if [ $a != 0 ]; then
  echo "Extracting clang failed (exit code = "$a")!"
  exit $a
fi

if [ ! -d $LLVM_BUILD_DIR ]; then
  mkdir $LLVM_BUILD_DIR
fi

cd $LLVM_BUILD_DIR
echo "CDing into the build dir ${LLVM_BUILD_DIR}"
echo "Generating makefiles for LLVM with clang for MIPS without FGPU!"
cmake -DCMAKE_CXX_COMPILER=g++ -DCMAKE_C_COMPILER=gcc -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD="Mips" -G "Unix Makefiles" $LLVM_SRC_DIR

a=$?
if [ $a != 0 ]; then
  echo "cmake failed (exit code = "$a")!"
  exit $a
fi

echo "Compiling LLVM with clang!"
make -j$N_THREADS

a=$?
if [ $a != 0 ]; then
  echo "Compilation failed (exit code = "$a")!"
  exit $a
fi

echo "clang source files will be deleted (to avoid recompiling clang when recompiling llvm)!"
rm -rf $LLVM_SRC_DIR/tools/$CLANG_SRC_NAME.src

a=$?
if [ $a != 0 ]; then
  echo "Deleting clang source files (exit code = "$a")!"
  exit $a
fi

echo "Adding FGPU backend files to the LLVM source directory!"
ln -sf ${LLVM_FGPU_SRC_DIR}"/CMakeLists.txt" ${LLVM_SRC_DIR}
ln -sf ${LLVM_FGPU_SRC_DIR}"/cmake/config-ix.cmake" ${LLVM_SRC_DIR}"/cmake/"
ln -sf ${LLVM_FGPU_SRC_DIR}"/include/llvm/ADT/Triple.h" ${LLVM_SRC_DIR}"/include/llvm/ADT/"
ln -sf ${LLVM_FGPU_SRC_DIR}"/include/llvm/Object/ELFObjectFile.h" ${LLVM_SRC_DIR}"/include/llvm/Object/"
ln -sf ${LLVM_FGPU_SRC_DIR}"/include/llvm/Support/ELF.h" ${LLVM_SRC_DIR}"/include/llvm/Support/"
ln -sf ${LLVM_FGPU_SRC_DIR}"/lib/Support/Triple.cpp" ${LLVM_SRC_DIR}"/lib/Support/"
ln -sf ${LLVM_FGPU_SRC_DIR}"/lib/Target/LLVMBuild.txt" ${LLVM_SRC_DIR}"/lib/Target/"
ln -sf ${LLVM_FGPU_SRC_DIR}"/lib/Target/Fgpu" ${LLVM_SRC_DIR}"/lib/Target/"

echo "Generating makefiles for LLVM and FGPU!"
cmake -DCMAKE_CXX_COMPILER=g++ -DCMAKE_C_COMPILER=gcc -DCMAKE_BUILD_TYPE=$COMPILE_STRATEGY -DLLVM_TARGETS_TO_BUILD="Fgpu" -G "Unix Makefiles" $LLVM_SRC_DIR

a=$?
if [ $a != 0 ]; then
  echo "cmake failed (exit code = "$a")!"
  exit $a
fi

echo "Compiling LLVM for FGPU!"
make -j$N_THREADS

a=$?
if [ $a != 0 ]; then
  echo "Compilation failed (exit code = "$a")!"
  exit $a
else
  echo "Compilation succeeded!"
fi
