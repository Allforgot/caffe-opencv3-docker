FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04
LABEL maintainers="Tan Zhenxing <imzero28@hotmail.com>"

WORKDIR /app
COPY . .

# Get Caffe and OpenCV dependencies
RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
    mv sources.list /etc/apt/ && \
    apt-get update && apt-get remove -y x264 libx264-dev && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends libboost-all-dev && \
    apt-get install -y sudo clang-format wget apt-utils \
        libprotobuf-dev libleveldb-dev libsnappy-dev libhdf5-serial-dev protobuf-compiler \
        libatlas-base-dev libgflags-dev libgoogle-glog-dev liblmdb-dev \
        python-dev python-numpy python-scipy libopenblas-dev && \
    apt-get install -y build-essential checkinstall cmake pkg-config yasm git \
        gfortran libjpeg8-dev libjasper-dev libpng12-dev libtiff5-dev libavcodec-dev libavformat-dev \
        libswscale-dev libdc1394-22-dev libxine2-dev libv4l-dev libgstreamer0.10-dev \
        libgstreamer-plugins-base0.10-dev qt5-default libgtk2.0-dev libtbb-dev \
        libfaac-dev libmp3lame-dev libtheora-dev libvorbis-dev libxvidcore-dev libopencore-amrnb-dev \
        libopencore-amrwb-dev x264 v4l-utils \
        libgphoto2-dev libeigen3-dev libhdf5-dev doxygen \
        python-pip python3-dev python3-pip && \
    rm -rf /var/lib/apt/lists/* && \
    pip2 install -U pip numpy && \
    pip3 install -U pip numpy && \
    pip install numpy scipy matplotlib scikit-image scikit-learn ipython

# Fetch OpenCV
RUN cd /opt && git clone --verbose https://github.com/opencv/opencv.git -b 3.4.1 && \
    cd /opt && wget https://github.com/opencv/opencv_contrib/archive/3.4.1.tar.gz && \
    mkdir opencv_contrib && tar -xf 3.4.1.tar.gz -C opencv_contrib --strip-components 1 && \
    cd /opt/opencv && mkdir release && cd release && \
    cmake -G "Unix Makefiles" -DENABLE_PRECOMPILED_HEADERS=OFF -DCMAKE_CXX_COMPILER=/usr/bin/g++ \
    CMAKE_C_COMPILER=/usr/bin/gcc -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DWITH_TBB=ON -DBUILD_NEW_PYTHON_SUPPORT=ON -DWITH_V4L=ON -DINSTALL_C_EXAMPLES=ON \
    -DINSTALL_PYTHON_EXAMPLES=ON -DBUILD_EXAMPLES=OFF -DWITH_QT=ON -DWITH_OPENGL=ON \
    -DWITH_CUDA=ON -DCUDA_GENERATION=Auto -DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
    .. &&\
    make -j"$(nproc)"  && \
    make install && \
    ldconfig &&\
    cd /opt/opencv/release && make clean

# Install Caffe
ENV CAFFE_ROOT=/opt/caffe
ENV CLONE_TAG=1.0
WORKDIR $CAFFE_ROOT

RUN git clone -b ${CLONE_TAG} --depth 1 https://github.com/BVLC/caffe.git . && \
    mv -f /app/Makefile.config $CAFFE_ROOT/ && \
    mv -f /app/Makefile $CAFFE_ROOT/ && \
    cd python && for req in $(cat requirements.txt) pydot; do pip3 install $req; done && cd .. && \
    git clone https://github.com/NVIDIA/nccl.git && cd nccl && \ 
    make -j"$(nproc)" CUDA8_GENCODE="-gencode=arch=compute_35,code=sm_35 -gencode=arch=compute_50,code=sm_50 \ 
        -gencode=arch=compute_60,code=sm_60 -gencode=arch=compute_61,code=sm_61" install && \ 
    cd .. && rm -rf nccl && \
    ln -s /usr/lib/x86_64-linux-gnu/libboost_python-py35.so /usr/lib/x86_64-linux-gnu/libboost_python3.so && \
    make all -j"$(nproc)" && \
    make pycaffe -j"$(nproc)"

ENV PYCAFFE_ROOT $CAFFE_ROOT/python
ENV PYTHONPATH $PYCAFFE_ROOT:$PYTHONPATH
ENV PATH $CAFFE_ROOT/build/tools:$PYCAFFE_ROOT:$PATH
RUN echo "$CAFFE_ROOT/build/lib" >> /etc/ld.so.conf.d/caffe.conf && ldconfig

WORKDIR /workspace