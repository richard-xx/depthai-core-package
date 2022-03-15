echo "Apply the patch"
git clone --recursive https://github.com/luxonis/depthai-core.git --depth 1 --shallow-submodules --branch v2.15.0 /workdir/depthai-core \
&& cd /workdir/depthai-core \
&& git apply /workdir/depthai-core-package.diff

echo "Build"
cd /workdir \
&& env CC=clang-10 CXX=clang++-10 LD=ld.lld-10 \
cmake -S depthai-core \
-B depthai-core/build \
-DBUILD_SHARED_LIBS=ON \
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_INSTALL_PREFIX=/usr/local \
&& cmake --build depthai-core/build --config Release --target package -- -j

mkdir -p /workdir/artifacts
cp /workdir/depthai-core/build/*.deb /workdir/artifacts/ \
&& cp /workdir/depthai-core/build/*.xz /workdir/artifacts/