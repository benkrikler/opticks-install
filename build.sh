#! /bin/bash
#set -x

### Config
PackagesToInstall=( zip unzip doxygen libX11-devel libGL-devel libXrandr-devel libXinerama-devel libXcursor-devel mesa-libGLU-devel openssl-devel xerces-c-devel tkinter mesa-dri-drivers mesa-libGLES mesa-libGL-devel mesa-libGLw mesa-libGLw-devel libXi-devel freeglut-devel freeglut )
PythonPackagesToAdd=( lxml matplotlib )
WorkPackages=( patch )

ScriptDir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
BuildDir="$(readlink -f "${1:-/opt/opticks_stuff}" )"
#CustomBuild="$2"
CustomBuild="$ScriptDir/custom_compile.sh"

PatchFile="$ScriptDir"/opticks.patch
ProfileFile="$BuildDir"/profile.sh
Geant4Home=/opt/geant/Geant4-10.3.3-Linux/
ClhepHome=/opt/clhep/
OptixHome=/opt/NVIDIA-OptiX-SDK-4.1.1-linux64/

#### Run things

yum -y install "${WorkPackages[@]}" ${PackagesToInstall[@]}
pip install ${PythonPackagesToAdd[@]}
# yum remove -y xerces-c xerces-c-devel
# Custom install cmake 3.10:
#bash /work/cmake-3.10.1-Linux-x86_64.sh --prefix=/usr --skip-license

[ ! -d "${BuildDir}" ] &&  mkdir "${BuildDir}"
cd "${BuildDir}"

hg clone http://bitbucket.org/simoncblyth/opticks

# Apply patches (if any)
if [ -n "$PatchFile" ];then
    (
    cd opticks
    patch -N -p 1 < "$PatchFile"
    )
fi

# Setup the environment
cat > "$ProfileFile" <<"EOF"
export OPTICKS_HOME="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"/opticks
export OPTICKS_GEANT4_HOME="$G4_INSTALL_DIR"
export OPTICKS_OPTIX_INSTALL_DIR="/opt/Optix"
export OPTICKS_COMPUTE_CAPABILITY=61
export XERCESC_INCLUDE_DIR=/usr/include/xercesc
export XERCESC_LIBRARY=/usr/lib64
export XERCESC_ROOT_DIR=/usr

opticks-(){ . $OPTICKS_HOME/opticks.bash && opticks-env $* ; }
export LOCAL_BASE=/usr/local

op(){ op.sh $* ; }

export PYTHONPATH="$(dirname $OPTICKS_HOME)"
export PATH=$LOCAL_BASE/opticks/lib:$OPTICKS_HOME/bin:$OPTICKS_HOME/ana:$PATH
export IDPATH=/usr/local/opticks/opticksdata/export/DayaBay_VGDX_20140414-1300/g4_00.96ff965744a2f6b78c24e33c80d3a4cd.dae
EOF
source "$ProfileFile"

# Need to set up things for the externals that opticks doesn't provide
ln -s "$OptixHome" /opt/Optix
ln -s "/usr/local/cuda-9.0/" "/usr/local/cuda-9.0.176/"

# Run the opticks installation process
if [ -z "$CustomBuild" ];then
	opticks-

	opticks-configure -DOptiX_INSTALL_DIR=/opt/Optix
	#                  -DCUDA_TOOLKIT_ROOT_DIR=/Developer/NVIDIA/CUDA-7.0 \
	#                  -DCOMPUTE_CAPABILITY=52 \
	#                  -DBOOST_ROOT=$(boost-prefix)

	opticks-full
else
	"$CustomBuild" "$ProfileFile"
fi

echo -e "================================================\n== Run Opticks Tests\n================================================"
opticks-
op -G
opticks-t -V
