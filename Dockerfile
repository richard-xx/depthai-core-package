FROM ubuntu:18.04
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ='Asia/Shanghai'
SHELL ["/bin/bash","-c"]

# sed -i "s@http://.*.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && sed -i "s@http://.*.ubuntu.com@http://mirrors.ustc.edu.cn@g" /etc/apt/sources.list \
    && apt update -qq \
    && apt install --no-install-recommends -qq -y apt-utils dialog \
    && apt install --no-install-recommends -qq -y curl wget git build-essential gnupg \
    libusb-1.0-0-dev cmake ca-certificates ccache pkg-config python3-distutils \
    clang-10 llvm-10 lldb-10 lld-10 clang-format-10 \
    && if [[ "$(uname -m)" =~ *86* ]]; then \
    apt-get --no-install-recommends -y install gcc-multilib g++-multilib ;\
    fi \
    && apt clean autoclean \
    && rm -rf /var/lib/{apt,cache,log} \
    && echo "[global]" >> /etc/pip.conf \
    && echo "index-url=https://repo.huaweicloud.com/repository/pypi/simple" >> /etc/pip.conf \
    && echo "trusted-host=repo.huaweicloud.com" >> /etc/pip.conf \
    && curl -sSL https://bootstrap.pypa.io/pip/3.6/get-pip.py | python3 - \
    && if [[ "$(uname -m)" =~ *arm* ]]; then \
    env CC=clang-10 CXX=clang++-10 LD=ld.lld-10 python3 -m pip install git+https://github.com/scikit-build/cmake-python-distributions.git git+https://github.com/scikit-build/ninja-python-distributions.git ;\
    else \
    python3 -m pip install cmake ninja ;\
    fi 


RUN mkdir -p ~/opencv_build \
    && cd ~/opencv_build \
    && git clone https://github.com/opencv/opencv.git -b 4.1.0 --depth 1 \
    && env CC=clang-10 CXX=clang++-10 LD=ld.lld-10 \
    cmake -S opencv -B build -D CMAKE_BUILD_TYPE=RELEASE \
    -D BUILD_SHARED_LIBS=OFF \
    -D OPENCV_GENERATE_PKGCONFIG=ON \
    -D BUILD_DOCS=OFF \
    -D BUILD_TESTS=OFF \
    -D BUILD_opencv_apps=OFF \
    -D BUILD_opencv_python2=OFF \
    -D BUILD_opencv_python3=OFF \
    -D OPENCV_FORCE_3RDPARTY_BUILD=ON \
    -G Ninja \
    -D BUILD_LIST=core,imgproc \
    && cmake --build . --config Release --target install/strip \
    && rm -rf ~/opencv_build


RUN adduser --shell /bin/bash --disabled-password --gecos "" ubuntu \
    && adduser ubuntu sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers 

USER ubuntu
WORKDIR /workdir 
