# OpenCvSharp-runtime

This repository stores the OpenCvSharp runtime. I also leave instructions for running it primarily on linux.  

If you don't want to install build tools on your local environment, you can use libOpenCvSharpExtern.so alone extracted from running container.  

### How to use the runtime

As [the official](https://github.com/shimat/opencvsharp) say, you need to set environmental variables.  
```
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/** absolute directory path where libOpenCvSharpExtern.so exists **"
```

### How to create your custom runtime by Dockerfile

Firstly specify the linux distribution, dotnet version to build, and OpenCV version. Whether or not build with gstreamer is to be rewritten inside of the file.  
[Here](https://hub.docker.com/_/microsoft-dotnet-aspnet/) is the base-image tag collection.  

And then, do the following.  
```
docker build -t IMAGE_NAME --build-arg ubuntu=jammy --build-arg dotnet=7.0 --build-arg opencv=4.7.0 .
```

### How to fix the dependencies relation

Please use ldd command.  
```
ldd /** absolute path **/libOpenCvSharpExtern.so
```
And just install the missing elements.