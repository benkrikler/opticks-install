#! /bin/bash
set -x

### Config
PackagesToInstall=( zip unzip doxygen libX11-devel libGL-devel libXrandr-devel libXinerama-devel )
WorkPackages=( patch )
ScriptDir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
BuildDir="$(readlink -f "${1:-/opt/opticks_stuff}" )"
PatchFile="$ScriptDir"/opticks.patch
ProfileFile="$BuildDir"/profile.sh

#### Run things

yum -y install "${WorkPackages[@]}" ${PackagesToInstall[@]}

[ ! -d "${BuildDir}" ] &&  mkdir "${BuildDir}"
cd "${BuildDir}"

hg clone http://bitbucket.org/simoncblyth/opticks                               

# Apply patches (if any)
if [ -f "$PatchFile" ];then
    ( 
    cd opticks
    patch -p 1 < "$PatchFile"
    )
fi

# Setup the environment
cat > "$ProfileFile" <<"EOF"
export OPTICKS_HOME="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"/opticks   
opticks-(){ . $OPTICKS_HOME/opticks.bash && opticks-env $* ; }                  
export LOCAL_BASE=/usr/local                                                    
                                                                                
op(){ op.sh $* ; }                                                              
                                                                                
export PYTHONPATH=$OPTICKS_HOME                                                 
export PATH=$LOCAL_BASE/opticks/lib:$OPTICKS_HOME/bin:$PATH
EOF
source "$ProfileFile"

# Run the opticks installation process
opticks-
opticks-full
