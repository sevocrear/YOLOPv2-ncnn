# Raspberry Pi 4
FROM ubuntu:22.04


# ===== INSTALL OPENCV =====
RUN apt-get update
RUN apt-get install cmake gfortran -y
RUN apt-get install python3-dev python3-numpy -y
RUN apt-get install libjpeg-dev libtiff-dev libgif-dev -y
RUN apt-get install libgstreamer1.0-dev gstreamer1.0-gtk3 -y
RUN apt-get install libgstreamer-plugins-base1.0-dev gstreamer1.0-gl -y
RUN apt-get install libavcodec-dev libavformat-dev libswscale-dev -y
RUN apt-get install libgtk2.0-dev libcanberra-gtk* -y
RUN apt-get install libxvidcore-dev libx264-dev libgtk-3-dev -y
RUN apt-get install libtbb2 libtbb-dev libdc1394-dev libv4l-dev -y
RUN apt-get install libopenblas-dev libatlas-base-dev libblas-dev -y
RUN apt-get install software-properties-common -y &&  \
 apt install liblapack-dev libhdf5-dev -y
RUN apt-get install protobuf-compiler -y

# check your memory first
RUN apt-get install wget -y
# you need at least a total of 6.5 GB!
# if not, enlarge your swap space as explained earlier
# download the latest version
WORKDIR ~/
RUN wget -O opencv.zip https://github.com/opencv/opencv/archive/4.5.5.zip
RUN wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.5.5.zip
# unpack
RUN apt-get install unzip -y
RUN unzip opencv.zip
RUN unzip opencv_contrib.zip
# some administration to make live easier later on
RUN mv opencv-4.5.5 opencv
RUN mv opencv_contrib-4.5.5 opencv_contrib
# clean up the zip files
RUN rm opencv.zip
RUN rm opencv_contrib.zip

RUN cd opencv && mkdir build && cd build && cmake -D CMAKE_BUILD_TYPE=RELEASE \
-D CMAKE_INSTALL_PREFIX=/usr/local \
-D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
-D ENABLE_NEON=ON \
-D BUILD_jasper=ON \
-D WITH_OPENMP=ON \
-D WITH_OPENCL=OFF \
-D BUILD_ZLIB=ON \
-D BUILD_TIFF=ON \
-D WITH_FFMPEG=ON \
-D WITH_TBB=ON \
-D BUILD_TBB=ON \
-D BUILD_TESTS=OFF \
-D WITH_EIGEN=OFF \
-D WITH_GSTREAMER=ON \
-D WITH_V4L=ON \
-D WITH_LIBV4L=ON \
-D WITH_VTK=OFF \
-D WITH_QT=OFF \
-D OPENCV_ENABLE_NONFREE=ON \
-D INSTALL_C_EXAMPLES=OFF \
-D INSTALL_PYTHON_EXAMPLES=OFF \
-D PYTHON3_PACKAGES_PATH=/usr/lib/python3/dist-packages \
-D OPENCV_GENERATE_PKGCONFIG=ON \
-D BUILD_EXAMPLES=OFF .. 
RUN cd opencv && cd build && make -j1
RUN cd opencv && cd build && make install
RUN rm -rf opencv/ && 	rm -rf opencv_contrib/
ARG DEBIAN_FRONTEND=noninteractive

# ==== INSTALL NCNN ====
# install dependencies
RUN apt-get install build-essential gcc g++ -y
RUN apt-get install libprotobuf-dev protobuf-compiler git -y
# download ncnn
RUN git clone --depth=1 https://github.com/Tencent/ncnn.git && cd ncnn && mkdir build && \
 cd build && cmake -D NCNN_DISABLE_RTTI=OFF -D NCNN_BUILD_TOOLS=ON \
-D CMAKE_TOOLCHAIN_FILE=../toolchains/aarch64-linux-gnu.toolchain.cmake .. && make -j2 && make install
# copy output to dirs
RUN mkdir /usr/local/lib/ncnn
RUN cd ncnn/build && cp -r install/include/ncnn /usr/local/include/ncnn
RUN cd ncnn/build && cp -r install/lib/libncnn.a /usr/local/lib/ncnn/libncnn.a

ARG UID
ARG GID
ARG UNAME
# ==== add USER ====
RUN groupadd -g ${GID} -o ${UNAME}
RUN useradd -m -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}
USER ${UNAME}
WORKDIR /home/${UNAME}
# cp /usr/local/lib/ncnn/libncnn.a lib/libncnn.a 
# cp -r /usr/local/include/ncnn include/ncnn