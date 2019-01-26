FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu16.04
LABEL maintainer eko.rudiawan@gmail.com

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    build-essential cmake git wget && \
    apt-get install -y --no-install-recommends \
    pkg-config unzip ffmpeg qtbase5-dev python-dev python-numpy python-py \
    libgtk2.0-dev libjpeg-dev libpng12-dev libtiff5-dev libjasper-dev zlib1g-dev libglew-dev libprotobuf-dev \
    libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libxine2-dev libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev \
    libv4l-dev libtbb-dev libfaac-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev \
    libvorbis-dev libxvidcore-dev v4l-utils libhdf5-serial-dev libeigen3-dev libtbb-dev libpostproc-dev apt-utils && \
    rm -rf /var/lib/apt/lists/*

# Build OpenCV with CUDA
ENV OPENCV_VERSION="4.0.1"
RUN \
    cd ~ && \
    rm -rf ~/opencv-${OPENCV_VERSION} && \
    rm -rf ~/opencv_contrib-${OPENCV_VERSION} && \
    wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip && \
    unzip ${OPENCV_VERSION}.zip && \
    rm ${OPENCV_VERSION}.zip && \
    wget https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip && \
    unzip ${OPENCV_VERSION}.zip && \
    rm ${OPENCV_VERSION}.zip && \
    mkdir ~/opencv-${OPENCV_VERSION}/build && \
    cd ~/opencv-${OPENCV_VERSION}/build && \
    cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DBUILD_EXAMPLES=OFF \
	-DBUILD_opencv_java=OFF \
	-DBUILD_opencv_python2=ON \
	-DBUILD_opencv_python3=OFF \
	-DWITH_FFMPEG=ON \
	-DWITH_CUDA=ON \
	-DWITH_GTK=ON \
	-DWITH_TBB=ON \
	-DWITH_V4L=ON \
	-DWITH_QT=ON \
	-DWITH_OPENGL=ON \
	-DWITH_CUBLAS=ON \	
	-DWITH_1394=OFF \
	-DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda-10.0 \
	-DCUDA_ARCH_PTX="" \
	-DCUDA_NVCC_FLAGS="-D_FORCE_INLINES" \ 
	-DCMAKE_LIBRARY_PATH=/usr/local/cuda/lib64/stubs \
	-DINSTALL_C_EXAMPLES=OFF \
	-DINSTALL_TESTS=OFF \
    -DOPENCV_EXTRA_MODULES_PATH=~/opencv_contrib-${OPENCV_VERSION}/modules .. && \
    make -j6 && \
    make install && \
    ldconfig && \
    cp ~/opencv-${OPENCV_VERSION}/build/lib/cv2.so /usr/local/lib/python2.7/dist-packages/ && \
    rm -rf ~/opencv-${OPENCV_VERSION}/build