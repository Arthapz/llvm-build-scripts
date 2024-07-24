cd ../llvm-project
git clean -dxf
git reset --hard
git pull

git apply -p1 -v "../llvm-build/65200.diff"
git apply -p1 -v "../llvm-build/65536.diff"
git apply -p1 -v "../llvm-build/73617.diff"
git apply -p1 -v "../llvm-build/158450.diff"

let clangd_dir = $"($env.TEMP)/clangd"
if ($clangd_dir | path exists) {
let current_path = $env.PWD
    cd $clangd_dir
    git pull
    cd $current_path
} else {
    git clone https://github.com/Arthapz/clangd-for-modules --depth 1 $clangd_dir
    rm -rf clang-tools-extra/clangd
    cp -r $"($clangd_dir)/clang-tools-extra/clangd" clang-tools-extra/
}

cd ../llvm-build/

(cmake
  -G Ninja
  -S "../llvm-project/llvm"
  -B build
  -D CMAKE_BUILD_TYPE=Release
  -D CMAKE_INSTALL_PREFIX="F:/llvm-19/"
  -D LLVM_APPEND_VC_REV=ON
  -D LLVM_VERSION_SUFFIX=""
  -D LLVM_ENABLE_RTTI=ON
  -D LLVM_ENABLE_FFI=ON
  -D LLVM_ENABLE_BINDINGS=OFF
  -D LLVM_ENABLE_WARNINGS=OFF
  -D LLVM_INSTALL_UTILS=ON
  -D LLVM_BUILD_DOCS=OFF
  -D LLVM_ENABLE_DOXYGEN=OFF
  -D LLVM_ENABLE_SPHINX=OFF
  -D SPHINX_OUTPUT_HTML:BOOL=OFF
  -D SPHINX_WARNINGS_AS_ERRORS=OFF
  -D POLLY_ENABLE_GPGPU_CODEGEN=ON
  -D LLDB_USE_SYSTEM_SIX=1
  -D LLVM_ENABLE_PROJECTS="polly;lldb;lld;clang;clang-tools-extra"
  -D LLVM_ENABLE_RUNTIMES="compiler-rt;libunwind;libcxx;libcxxabi"
  -D LLVM_ENABLE_LTO=OFF
  -D LLVM_LIT_ARGS="-sv --ignore-fail"
  -D LLVM_ENABLE_DUMP=ON
  -D LIBCXX_INSTALL_MODULES=ON
  -D LIBCXX_ENABLE_INCOMPLETE_FEATURES=ON
  -Wno-dev)

cmake --build build --parallel
