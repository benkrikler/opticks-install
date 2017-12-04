#! /bin/bash
#set -x

### Config
PackagesToInstall=( zip unzip doxygen libX11-devel libGL-devel libXrandr-devel libXinerama-devel libXcursor-devel mesa-libGLU-devel openssl-devel xerces-c-devel )
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

[ ! -d "${BuildDir}" ] &&  mkdir "${BuildDir}"
cd "${BuildDir}"

hg clone http://bitbucket.org/simoncblyth/opticks                               

# Apply patches (if any)
if [ -f "$PatchFile" ];then
    ( 
    cd opticks
    patch -N -p 1 < "$PatchFile"
    )
fi

# Setup the environment
cat > "$ProfileFile" <<"EOF"
export OPTICKS_HOME="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"/opticks   
export OPTICKS_GEANT4_HOME="/opt/geant/Geant4-10.3.3-Linux/"
#export OPTICKS_CLHEP_HOME="/opt/clhep/"
export OPTICKS_OPTIX_HOME="/opt"
export OPTICKS_CAPABILITY=30

opticks-(){ . $OPTICKS_HOME/opticks.bash && opticks-env $* ; }                  
export LOCAL_BASE=/usr/local                                                    
                                                                                
op(){ op.sh $* ; }                                                              
                                                                                
export PYTHONPATH=$OPTICKS_HOME                                                 
export PATH=$LOCAL_BASE/opticks/lib:$OPTICKS_HOME/bin:$PATH
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
