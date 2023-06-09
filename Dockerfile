ARG dotnet
ARG ubuntu
FROM mcr.microsoft.com/dotnet/aspnet:${dotnet}-${ubuntu} as builder

ARG opencv
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /

# Install opencv dependencies
RUN apt-get update && apt-get -y install --no-install-recommends \
    apt-transport-https software-properties-common \
    wget unzip ca-certificates build-essential cmake git \
    libtbb-dev libatlas-base-dev libgtk2.0-dev libavcodec-dev \
    libavformat-dev libswscale-dev libdc1394-dev libxine2-dev \
    libv4l-dev libtheora-dev libvorbis-dev libxvidcore-dev \
    libopencore-amrnb-dev libopencore-amrwb-dev x264 \
    libtesseract-dev libgdiplus

# if with GStreamer
# RUN apt-get update && apt-get -y install --no-install-recommends \
#     libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer1.0-0 \
#     gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly \
#     gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl \
#     gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio
# endif

RUN apt-get -y clean && rm -rf /var/lib/apt/lists/*

# Setup opencv and opencv-contrib source
RUN wget -q https://github.com/opencv/opencv/archive/${opencv}.zip && \
    unzip -q ${opencv}.zip && \
    rm ${opencv}.zip && \
    mv opencv-${opencv} opencv && \
    wget -q https://github.com/opencv/opencv_contrib/archive/${opencv}.zip && \
    unzip -q ${opencv}.zip && \
    rm ${opencv}.zip && \
    mv opencv_contrib-${opencv} opencv_contrib

# Build OpenCV
RUN cd opencv && mkdir build && cd build && \
    cmake \
    -D OPENCV_EXTRA_MODULES_PATH=/opencv_contrib/modules \
    -D CMAKE_BUILD_TYPE=RELEASE \
    -D BUILD_SHARED_LIBS=OFF \
    -D ENABLE_CXX11=ON \
    -D BUILD_EXAMPLES=OFF \
    -D BUILD_DOCS=OFF \
    -D BUILD_PERF_TESTS=OFF \
    -D BUILD_TESTS=OFF \
    -D BUILD_JAVA=OFF \
    -D BUILD_opencv_app=OFF \
    -D BUILD_opencv_barcode=OFF \
    -D BUILD_opencv_java_bindings_generator=OFF \
    -D BUILD_opencv_js_bindings_generator=OFF \
    -D BUILD_opencv_python_bindings_generator=OFF \
    -D BUILD_opencv_python_tests=OFF \
    -D BUILD_opencv_ts=OFF \
    -D BUILD_opencv_js=OFF \
    -D BUILD_opencv_bioinspired=OFF \
    -D BUILD_opencv_ccalib=OFF \
    -D BUILD_opencv_datasets=OFF \
    -D BUILD_opencv_dnn_objdetect=OFF \
    -D BUILD_opencv_dpm=OFF \
    -D BUILD_opencv_fuzzy=OFF \
    -D BUILD_opencv_gapi=OFF \
    -D BUILD_opencv_intensity_transform=OFF \
    -D BUILD_opencv_mcc=OFF \
    -D BUILD_opencv_objc_bindings_generator=OFF \
    -D BUILD_opencv_rapid=OFF \
    -D BUILD_opencv_reg=OFF \
    -D BUILD_opencv_stereo=OFF \
    -D BUILD_opencv_structured_light=OFF \
    -D BUILD_opencv_surface_matching=OFF \
    -D BUILD_opencv_videostab=OFF \
    -D BUILD_opencv_wechat_qrcode=ON \
# if with GStreamer
    # -D WITH_GSTREAMER=ON \
    # -D WITH_1394=OFF \
    # -D WITH_FFMPEG=OFF \
# endif
    -D WITH_ADE=OFF \
    -D OPENCV_ENABLE_NONFREE=ON \
    .. && make -j$(nproc) && make install && ldconfig

# Download OpenCvSharp
RUN git clone https://github.com/shimat/opencvsharp.git && cd opencvsharp

# Install the Extern lib.
RUN mkdir /opencvsharp/make && cd /opencvsharp/make && \
    cmake -D CMAKE_INSTALL_PREFIX=/opencvsharp/make /opencvsharp/src && \
    make -j$(nproc) && make install && \
    rm -rf /opencv && \
    rm -rf /opencv_contrib && \
    cp /opencvsharp/make/OpenCvSharpExtern/libOpenCvSharpExtern.so /usr/lib/

########## Final image ##########

ARG dotnet
ARG ubuntu
FROM mcr.microsoft.com/dotnet/sdk:${dotnet}-${ubuntu} as final
COPY --from=builder /usr/lib /usr/lib