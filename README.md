# YOLOPv2-ncnn

# Build docker
```
docker build --build-arg UID="$(id -u)" --build-arg GID="$(id -g)" --build-arg UNAME="$(whoami)" -t ubuntu-22.04-opencv .
```

# Run docker container
```
docker run --rm -it --net=host --ipc=host -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/.Xauthority:/home/"$(whoami)"/.Xauthority -v $PWD:/home/"$(whoami)"/ --name yolopv2 ubuntu-22.04-opencv
```

```
mkdir build
cd build 
cmake ..
make 
./yolopv2_ncnn ../images
```

## screenshot
![](screenshot.jpg)  
![](screenshot_android.jpg)

## reference  
https://github.com/Tencent/ncnn  
https://github.com/CAIC-AD/YOLOPv2  
