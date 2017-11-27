Get the code:
```
git clone https://lz-git.ua.edu/BenKrikler/opticks-install.git 
cd opticks-install
```
Fire up the container
```
docker run --runtime=nvidia -v $PWD:/work -ti kreczko/optix-build
```

Run the build script
```
cd /work
./build.sh
```
