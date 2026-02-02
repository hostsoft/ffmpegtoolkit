#!/usr/bin/env bash
# kvazaar - HEVC encoder (Git-based)

build_kvazaar() {
    local name="kvazaar"
    local srcdir="$BUILD_DIR/kvazaar"
    [[ -d "$srcdir" ]] && rm -rf "$srcdir"

    git clone --depth 1 https://github.com/ultravideo/kvazaar.git "$srcdir"
    cd "$srcdir" || return 1
    ./autogen.sh
    ./configure --prefix="$PREFIX" --enable-static --disable-shared || return 1
    safe_make || return 1
    make install || return 1

    cd "$TOOLKIT_ROOT" || true
    rm -rf "$srcdir"
    touch "${BUILD_DIR}/.done_${name}"
}
