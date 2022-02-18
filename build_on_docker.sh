echo "Install some dependencies in the container."
export TZ='Asia/Shanghai'
ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
apt update -qq && apt install -q -y dialog apt-utils && apt install -q -y curl wget git build-essential libusb-1.0-0-dev cmake clang-format 
if [ ${SHARED} = "Static" ]
then
    apt install -q -y libopencv-dev
fi
mkdir -p /workdir/artifacts 

echo "Apply the patch"
git clone --recursive https://github.com/luxonis/depthai-core.git --branch main /workdir/depthai-core \
cd /workdir/depthai-core \
&& git apply /workdir/depthai-core-package.patch
# && cat Cpack.txt >> CMakeLists.txt


if [ ${SHARED} = "Static" ]
then
    echo "Build"
    cd /workdir \
    && cmake -S . -Bbuild -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local \
    && cmake --build build --config Release --target package -- -j4
else
    echo "Build"
    cd /workdir \
    && cmake -S . -Bbuild -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local \
    && cmake --build build --config Release --target package -- -j4
fi

chown -R 1000:1000 /workdir/build/* \
    && cp /workdir/build/*.deb /workdir/artifacts/ \
    && cp /workdir/build/*.xz /workdir/artifacts
