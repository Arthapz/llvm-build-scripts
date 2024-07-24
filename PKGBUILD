# Maintainer: Reza Jahanbakhshi <reza.jahanbakhshi at gmail dot com
# Contributor: Lone_Wolf <lone_wolf@klaas-de-kat.nl>
# Contributor: yurikoles <root@yurikoles.com>
# Contributor: bearoso <bearoso@gmail.com>
# Contributor: Luchesar V. ILIEV <luchesar%2eiliev%40gmail%2ecom>
# Contributor: Anders Bergh <anders@archlinuxppc.org>
# Contributor: Armin K. <krejzi at email dot com>
# Contributor: Christian Babeux <christian.babeux@0x80.ca>
# Contributor: Jan "heftig" Steffens <jan.steffens@gmail.com>
# Contributor: Evangelos Foutras <evangelos@foutrelis.com>
# Contributor: Hesiod (https://github.com/hesiod)
# Contributor: Roberto Alsina <ralsina@kde.org>
# Contributor: Thomas Dziedzic < gostrc at gmail >
# Contributor: Tomas Lindquist Olsen <tomas@famolsen.dk>
# Contributor: Tomas Wilhelmsson <tomas.wilhelmsson@gmail.com>

pkgname=('llvm-git' 'llvm-libs-git')
pkgver=19.0.0_r505935.d48d4805f792
pkgrel=1
arch=('x86_64')
url="https://llvm.org/"
license=('custom:Apache 2.0 with LLVM Exception')
makedepends=('git' 'cmake' 'ninja' 'libffi' 'libedit' 'ncurses' 'libxml2' 
             'python-setuptools' 'lldb' 'ocaml' 'ocaml-ctypes' 'ocaml-findlib'
             'python-sphinx' 'python-recommonmark' 'swig' 'python' 'python-six'
             'python-myst-parser' 'lua53' 'ocl-icd' 'opencl-headers' 'z3'
             'jsoncpp' 'ocaml-stdlib-shims')
checkdepends=("python-psutil")
source=("git+https://github.com/llvm/llvm-project.git"
    "llvm-config.h"
    "65200.diff" # std::ranges::stride_view
  "65536.diff" # std::ranges::join_with
  "73617.diff" # std::ranges::enumerate_view
  "66462.diff") # clangd

md5sums=('SKIP'
    'SKIP'
    'SKIP'
    'SKIP'
    'SKIP'
  'SKIP')
sha512sums=('SKIP'
    '75e743dea28b280943b3cc7f8bbb871b57d110a7f2b9da2e6845c1c36bf170dd883fca54e463f5f49e0c3effe07fbd0db0f8cf5a12a2469d3f792af21a73fcdd'
    'SKIP'
    'SKIP'
    'SKIP'
  'SKIP')
options=('staticlibs' '!debug' '!strip')

# NINJAFLAGS is an env var used to pass commandline options to ninja
# NOTE: It's your responbility to validate the value of $NINJAFLAGS. If unsure, don't set it.
# NINJAFLAGS="-j20"

_python_optimize() {
    python -m compileall "$@"
    python -O -m compileall "$@"
    python -OO -m compileall "$@"
}

pkgver() {
    cd llvm-project/cmake/Modules

    # This will almost match the output of `llvm-config --version` when the
    # LLVM_APPEND_VC_REV cmake flag is turned on. The only difference is
    # dash being replaced with underscore because of Pacman requirements.
    local _pkgver=$(awk -F 'MAJOR |MINOR |PATCH |)' \
            'BEGIN { ORS="." ; i=0 } \
             /set\(LLVM_VERSION_/ { print $2 ; i++ ; if (i==2) ORS="" } \
             END { print "\n" }' \
             LLVMVersion.cmake)_r$(git rev-list --count HEAD).$(git rev-parse --short HEAD)
    echo "$_pkgver"
}

prepare() {
    cd llvm-project

    git clean -dxf
    git reset --hard

    git apply -p1 -v "$srcdir/65200.diff"
    git apply -p1 -v "$srcdir/65536.diff"
    git apply -p1 -v "$srcdir/73617.diff"
    # git apply -p1 -v "$srcdir/66462.diff"
    #
    git clone https://github.com/Arthapz/clangd-for-modules --depth 1 /tmp/clangd
    rm -rf clang-tools-extra/clangd
    cp -r /tmp/clangd/clang-tools-extra/clangd clang-tools-extra/
}

build() {
    export OLDCFLAGS=" ${CFLAGS}"
    export OLDCXXFLAGS=" ${CPPFLAGS}"

    export CFLAGS+=" ${CFLAGS} -flto=auto"
    export CXXFLAGS+=" ${CPPFLAGS} -flto=auto"

    cd "$srcdir/llvm-project"

    cmake \
      -G Ninja \
      -B "$srcdir"/llvm-project-build \
      -S llvm \
      -D CMAKE_BUILD_TYPE=Release \
      -D CMAKE_INSTALL_PREFIX=/opt/llvm-git/ \
      -D LLVM_BINUTILS_INCDIR=/opt/llvm-git/include \
      -D LLVM_APPEND_VC_REV=ON \
      -D LLVM_VERSION_SUFFIX="" \
      -D LLVM_HOST_TRIPLE=$CHOST \
      -D LLVM_ENABLE_RTTI=ON \
      -D LLVM_ENABLE_FFI=ON \
      -D FFI_INCLUDE_DIR:PATH="$(pkg-config --variable=includedir libffi)" \
      -D LLVM_ENABLE_BINDINGS=OFF \
      -D LLVM_BUILD_LLVM_DYLIB=ON \
      -D LLVM_ENABLE_WARNINGS=OFF \
      -D LLVM_LINK_LLVM_DYLIB=ON \
      -D LLVM_INSTALL_UTILS=ON \
      -D LLVM_BUILD_DOCS=OFF \
      -D LLVM_ENABLE_DOXYGEN=OFF \
      -D LLVM_ENABLE_SPHINX=OFF \
      -D SPHINX_OUTPUT_HTML:BOOL=OFF \
      -D SPHINX_WARNINGS_AS_ERRORS=OFF \
      -D POLLY_ENABLE_GPGPU_CODEGEN=ON \
      -D LLDB_USE_SYSTEM_SIX=1 \
      -D LLVM_ENABLE_PROJECTS="polly;lldb;lld;clang;clang-tools-extra" \
      -D LLVM_ENABLE_LTO=OFF \
      -D LLVM_ENABLE_RUNTIMES="compiler-rt" \
      -D LLVM_LIT_ARGS="-sv --ignore-fail" \
      -D LLVM_ENABLE_DUMP=ON \
      -Wno-dev

    cmake --build "$srcdir"/llvm-project-build -j18

    # export CFLAGS="${OLDCFLAGS} -D_LIBUNWIND_USE_CET"
    # export CXXFLAGS="${OLDCXXFLAGS}"

    cmake \
      -G Ninja \
      -B "$srcdir"/llvm-project-build-runtimes \
      -S runtimes \
      -D CMAKE_C_COMPILER="$srcdir"/llvm-project-build/bin/clang \
      -D CMAKE_ASM_COMPILER="$srcdir"/llvm-project-build/bin/clang \
      -D CMAKE_CXX_COMPILER="$srcdir"/llvm-project-build/bin/clang++ \
      -D LLVM_CONFIG_PATH="$srcdir"/llvm-project-build/bin/llvm-config \
      -D LLVM_DIR="$srcdir"/llvm-project-build/lib/cmake/llvm \
      -D Clang_DIR="$srcdir"/llvm-project-build/lib/cmake/clang \
      -D CMAKE_BUILD_TYPE=Release \
      -D CMAKE_INSTALL_PREFIX=/opt/llvm-git/ \
      -D LLVM_BINUTILS_INCDIR=/opt/llvm-git/include \
      -D LLVM_APPEND_VC_REV=ON \
      -D LLVM_VERSION_SUFFIX="" \
      -D LLVM_HOST_TRIPLE=$CHOST \
      -D LLVM_ENABLE_WARNINGS=OFF \
      -D LLVM_BUILD_DOCS=OFF \
      -D LLVM_ENABLE_DOXYGEN=OFF \
      -D LLVM_ENABLE_SPHINX=OFF \
      -D SPHINX_OUTPUT_HTML:BOOL=OFF \
      -D SPHINX_WARNINGS_AS_ERRORS=OFF \
      -D POLLY_ENABLE_GPGPU_CODEGEN=ON \
      -D LIBCXX_ENABLE_INCOMPLETE_FEATURES=ON \
      -D LLVM_ENABLE_LTO=OFF \
      -D LLDB_USE_SYSTEM_SIX=1 \
      -D LLVM_ENABLE_PROJECTS="" \
      -D LLVM_ENABLE_RUNTIMES="libunwind;libcxx;libcxxabi" \
      -D LLVM_LIT_ARGS="-sv --ignore-fail" \
      -D LIBCXX_INSTALL_MODULES=ON \
      -D LLVM_ENABLE_DUMP=ON \
      -Wno-dev

    cmake --build "$srcdir"/llvm-project-build-runtimes -- $NINJAFLAGS
}

package_llvm-git() {
    pkgdesc="llvm-git"

    DESTDIR="$pkgdir" cmake --install "$srcdir"/llvm-project-build --prefix "/opt/llvm-git"
}

package_llvm-libs-git() {
    pkgdesc="runtime libraries for llvm-git"
    depends=('llvm-git' 'gcc-libs' 'zlib' 'libffi' 'libedit' 'ncurses' 'libxml2' 'z3' 'lua53')

    DESTDIR="$pkgdir" cmake --install "$srcdir"/llvm-project-build-runtimes --prefix "/opt/llvm-git"
}

