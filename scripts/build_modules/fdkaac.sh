#!/usr/bin/env bash
# fdk-aac - Fraunhofer AAC (Git-based)

build_fdkaac() {
    local name="fdkaac"
    local srcdir="$BUILD_DIR/fdk-aac"
    [[ -d "$srcdir" ]] && rm -rf "$srcdir"

    git clone https://github.com/mstorsjo/fdk-aac "$srcdir"
    cd "$srcdir" || return 1
    autoreconf -fiv
    ./configure --prefix="$PREFIX" --enable-static --disable-shared CFLAGS="-fPIC" || return 1
    safe_make || return 1
    make install || return 1

    cd "$TOOLKIT_ROOT" || true
    rm -rf "$srcdir"
    touch "${BUILD_DIR}/.done_${name}"
}
