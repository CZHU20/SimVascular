#!/bin/bash
#----------------------------------------------------------------------------
# Exports
#----------------------------------------------------------------------------
export cwd=$(pwd)
export BUILD_DIR=$cwd/build
export SV_EXTERNALS_DIR=$cwd/../Externals
export SV_CODE_DIR=$cwd/../Code
export SV_EXTERNALS_BUILD_DIR=$BUILD_DIR/externals-build
export SV_EXTERNALS_TOPLEVEL_DIR=$SV_EXTERNALS_BUILD_DIR/sv_externals
#cmake
export SV_CMAKE_CMD="cmake"
export SV_CMAKE_GENERATOR="Unix Makefiles"
export SV_CMAKE_BUILD_TYPE="RelWithDebInfo"
export SV_MAKE_CMD="make -j8"
#compilers
export CC="clang"
export CXX="clang++"
# Qt
export Qt5_URL=http://simvascular.stanford.edu/downloads/public/open_source/mac_osx/qt/5.4
#export Qt5_DIR="/opt/Qt5.4.2/5.4/clang_64/lib/cmake/Qt5"
export Qt5_DIR="/usr/local/package/Qt5.4.2/5.4/clang_64/lib/cmake/Qt5"
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# Qt
#----------------------------------------------------------------------------
#sudo mkdir -p /opt/Qt5.4.2
#sudo chmod -R a+rwx /opt/Qt5.4.2
#
#mkdir -p ~/tmp/tarfiles
#pushd ~/tmp/tarfiles
#curl -O $Qt5_URL/qt-opensource-mac-x64-clang-5.4.2.tar.gz
#echo "untarring (qt-opensource-mac-x64-clang-5.4.2.dmg)..."
#sudo tar --directory=/ -xzf ./qt-opensource-mac-x64-clang-5.4.2.tar.gz
#rm qt-opensource-mac-x64-clang-5.4.2.tar.gz
#popd
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# SimVascular Externals
#----------------------------------------------------------------------------
# Get externals
mkdir -p $SV_EXTERNALS_BUILD_DIR
pushd $SV_EXTERNALS_BUILD_DIR
"$SV_CMAKE_CMD" \
  -G "$SV_CMAKE_GENERATOR" \
  -Qt5_DIR=$Qt5_DIR \
 ../
$SV_MAKE_CMD
popd
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# SimVascular
#----------------------------------------------------------------------------

pushd $BUILD_DIR

"$SV_CMAKE_CMD" \
\
   -G "$SV_CMAKE_GENERATOR" \
\
   -DCMAKE_BUILD_TYPE="$SV_CMAKE_BUILD_TYPE" \
   -DBUILD_SHARED_LIBS=ON \
   -DBUILD_TESTING=ON \
   -DSV_TEST_DIR="/Users/adamupdegrove/Documents/Software/SimVascular/SimVascular-Test/automated_tests" \
\
   -DSV_USE_FREETYPE=ON \
   -DSV_USE_GDCM=ON \
   -DSV_USE_ITK=ON \
   -DSV_USE_MPICH2=OFF \
   -DSV_USE_OpenCASCADE=ON \
   -DSV_USE_PYTHON=ON \
   -DSV_USE_MMG=ON \
   -DSV_USE_MITK=ON \
   -DSV_USE_QT_GUI=ON \
\
   -DSV_USE_SYSTEM_FREETYPE=ON \
   -DSV_USE_SYSTEM_GDCM=ON \
   -DSV_USE_SYSTEM_ITK=ON \
   -DSV_USE_SYSTEM_PYTHON=ON \
   -DSV_USE_SYSTEM_OpenCASCADE=ON \
   -DSV_USE_SYSTEM_TCL=ON \
   -DSV_USE_SYSTEM_VTK=ON \
   -DSV_USE_SYSTEM_MMG=ON \
   -DSV_USE_SYSTEM_MITK=ON \
\
   -DSV_USE_GDCM_SHARED=ON \
   -DSV_USE_FREETYPE_SHARED=ON \
   -DSV_USE_ITK_SHARED=ON \
   -DSV_USE_OpenCASCADE_SHARED=ON \
   -DSV_USE_TCL_SHARED=ON \
   -DSV_USE_VTK_SHARED=ON \
   -DSV_USE_MITK_SHARED=ON \
\
   -DSV_DOWNLOAD_EXTERNALS=ON \
   -DSV_EXTERNALS_USE_TOPLEVEL_DIR=ON \
   -DSV_EXTERNALS_TOPLEVEL_DIR="$SV_EXTERNALS_TOPLEVEL_DIR" \
   -Qt5_DIR=$Qt5_DIR \
\
 "$SV_CODE_DIR"

$SV_MAKE_CMD
popd
#----------------------------------------------------------------------------
