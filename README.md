# Opticks in a Docker container
Trying to build and run Opticks from within a Docker container.
Developed on a machine with a NVIDIA GP102 Titan Xp -- not clear how this would work on other GPUs at this time.

## Instructions for use
1. Log in to machine (with x-forwarding enabled)
2. Change to the directory containing this README (or git clone this repo first)
3. Set up the x-display credentials:
```bash
source prepare_x11.sh
```
4. Run the docker container:
```bash
docker run --runtime=nvidia --rm -v $PWD:/work -e DISPLAY=$DISPLAY -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH -ti --net=host --name="${USER}_opticks_dev" --device /dev/input krikler/opticks-build:cuda9_x11
```
5. Check your X-window is ok:
```
xclock
```
6. Setup the Opticks environment and prepare the caches (for some reason, the cache building doesn't work during docker build, think this is due to the nvidia runtime)
```bash
source profile.sh 
opticks-
opticks-setup 
```
7. Run the opticks unit tests:
```
opticks-t 2>&1 |tee logs/run_tests.txt
```
Currently (21st Jan 2019) there are all but 4 of the 375 tests passing for me.
The remaining tests require OpenGL version 3.2 which is not yet fixed in this container (we think).

# Old instructions (before 21st Jan 2019)
Get the code:
```
git clone https://lz-git.ua.edu/BenKrikler/opticks-install.git 
cd opticks-install
```

Set up X-forwarding (especially if logged in to deepthought via ssh:
```
XAUTH=/tmp/$USER.docker.xauth
touch $XAUTH
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge - 
chmod 777 $XAUTH
```
Fire up the container
```
docker run --runtime=nvidia --rm -v $PWD:/work -v /software/LZ/geant4/v10.2.3/data/:/opt/geant4/share/Geant4-10.2.3/data -e DISPLAY=$DISPLAY -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH -ti --net=host --name="${USER}_opticks_dev" kreczko/optix-build:cuda8
```

Run the build script
```
cd /work
./build.sh 2>&1 |tee /tmp/build_log.txt
```

## Building the docker images, 23rd October 2018
You need to get hold of the Optix 5.1 SDK (needs you to make an account with NVidia)
https://developer.nvidia.com/designworks/optix/download

Put that into this directory (containing this README) and then do:
```
docker build --rm -t krikler/opticks-build:cuda9_x11 -f ./docker/Dockerfile_opticks .
```
