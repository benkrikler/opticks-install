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
docker run --runtime=nvidia --rm -v $PWD:/work -v /software/LZ/geant4/v10.2.3/data/:/opt/geant4/share/Geant4-10.2.3/data -e DISPLAY=$DISPLAY -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH -ti --net=host kreczko/optix-build:cuda8
```

Run the build script
```
cd /work
./build.sh 2>&1 |tee /tmp/build_log.txt
```
