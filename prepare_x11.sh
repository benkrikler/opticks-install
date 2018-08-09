XAUTH=/tmp/$USER.docker.xauth
touch $XAUTH
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge - 
chmod 777 $XAUTH
