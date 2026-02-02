#!/usr/bin/env bash
# zimg - scaling library (Git-based)

build_zimg() {
    local name="zimg"
    local srcdir="$BUILD_DIR/zimg"
    [[ -d "$srcdir" ]] && rm -rf "$srcdir"

    git clone --depth 1 --recurse-submodules https://github.com/sekrit-twc/zimg "$srcdir"
    cd "$srcdir" || return 1
    git submodule update --init --recursive
    ./autogen.sh
    ./configure --prefix="$PREFIX" --enable-static --disable-shared || return 1
    safe_make || return 1
    make install || return 1

    _merge_pkgconfig_to_lib
    cd "$TOOLKIT_ROOT" || true
    rm -rf "$srcdir"
    touch "${BUILD_DIR}/.done_${name}"
}
