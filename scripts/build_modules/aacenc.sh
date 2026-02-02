#!/usr/bin/env bash
# vo-aacenc - AAC encoder (Git-based)

build_aacenc() {
    local name="aacenc"
    local srcdir="$BUILD_DIR/vo-aacenc"
    [[ -d "$srcdir" ]] && rm -rf "$srcdir"

    git clone https://github.com/mstorsjo/vo-aacenc "$srcdir"
    cd "$srcdir" || return 1
    autoreconf -fiv
    ./configure --prefix="$PREFIX" --enable-static --disable-shared || return 1
    safe_make || return 1
    make install || return 1

    cd "$TOOLKIT_ROOT" || true
    rm -rf "$srcdir"
    touch "${BUILD_DIR}/.done_${name}"
}
