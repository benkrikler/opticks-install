#! /bin/bash
source $1

opticks-

opticks-info
#opticks-externals

echo "===\nInstall Oticks Externals\n==="
# The externals are pretty complicated, so leave this with Opticks for now
opticks-externals-install

## opticks-configure
### opticks-wipe
### opticks-cmake

echo "===\nConfigure Oticks\n==="
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
      -DGeant4_DIR=$(g4-cmake-dir)\
      -DXERCESC_LIBRARY=$(xercesc-library)\
      -DXERCESC_INCLUDE_DIR=$(xercesc-include-dir)\
      $* $(opticks-sdir)
)

echo "===\nBuild Oticks\n==="

## opticks--
#opticks-- () { 
(
    cd $(opticks-bdir);
    cmake --build . --config $(opticks-config-type) -- -j8
)

echo "===\nPrepare install cache\n==="

##opticks-prepare-installcache
#opticks-prepare-installcache () {   
(
    cudarap-
    cudarap-prepare-installcache
    OpticksPrepareInstallCache
)
