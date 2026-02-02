#!/usr/bin/env bash
# CELT codec (Git-based)

build_celt() {
    local name="celt"
    local srcdir="$BUILD_DIR/celt"
    [[ -d "$srcdir" ]] && rm -rf "$srcdir"

    git clone https://gitlab.xiph.org/xiph/celt "$srcdir"
    cd "$srcdir" || return 1
    ./autogen.sh
    ./configure --prefix="$PREFIX" --enable-static --disable-shared || return 1
    safe_make || return 1
    make install || return 1

    cd "$TOOLKIT_ROOT" || true
    rm -rf "$srcdir"
    touch "${BUILD_DIR}/.done_${name}"
}
