#!/usr/bin/env bash
# libvpx - VP8/VP9 (needs yasm)

build_vpx() {
    local name="vpx"
    local srcdir="$BUILD_DIR/libvpx"
    [[ -d "$srcdir" ]] && rm -rf "$srcdir"

    git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git "$srcdir"
    cd "$srcdir" || return 1
    ./configure --prefix="$PREFIX" --enable-static --disable-shared --disable-examples \
        --disable-unit-tests --enable-pic --enable-vp9 --enable-vp8 || return 1
    safe_make || return 1
    make install || return 1

    _merge_pkgconfig_to_lib
    cd "$TOOLKIT_ROOT" || true
    rm -rf "$srcdir"
    touch "${BUILD_DIR}/.done_${name}"
}
