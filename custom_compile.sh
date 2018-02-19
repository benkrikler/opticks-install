#! /bin/bash
source $1
set -x

opticks-

opticks-info
#opticks-externals

echo -e "================================================\n== Install Oticks Externals\n================================================"
# The externals are pretty complicated, so leave this with Opticks for now
opticks-externals-install

## opticks-configure
### opticks-wipe
### opticks-cmake

echo -e "================================================\n== Configure Oticks\n================================================"
# opticks-cmake () { 
(
bdir=$(opticks-bdir)
mkdir -p $bdir
opticks-bcd
g4-
xercesc-
opticks-cmake-info
cmake -G "$(opticks-cmake-generator)"\
      -DCMAKE_BUILD_TYPE=Debug\
      -DCOMPUTE_CAPABILITY=$(opticks-compute-capability)\
      -DCMAKE_INSTALL_PREFIX=$(opticks-prefix)\
      -DOptiX_INSTALL_DIR=$(opticks-optix-install-dir)\
      -DCMAKE_PREFIX_PATH=$(g4-prefix)\
      -DCMAKE_CXX_COMPILER=$(which g++)\
      -DCMAKE_C_COMPILER=$(which gcc)\
      -DXERCESC_LIBRARY=$(xercesc-library)\
      -DXERCESC_INCLUDE_DIR=$(xercesc-include-dir)\
      $* $(opticks-sdir)
)

echo -e "================================================\n== Build Oticks\n================================================"

## opticks--
#opticks-- () { 
(
    cd $(opticks-bdir);
    pwd
    cmake --build . --config $(opticks-config-type) --target install -- -j8

 # QUICK FIX: Run twice, it seems to solve a compile problem... WIERD!!!
    cmake --build . --config $(opticks-config-type) --target install -- -j8
)

echo -e "================================================\n== Prepare install cache\n================================================"

(
g4-
g4-export-ini
)

##opticks-prepare-installcache
#opticks-prepare-installcache () {   
(
    cudarap-
    cudarap-prepare-installcache
    OpticksPrepareInstallCache
)
