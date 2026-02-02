#!/usr/bin/env bash
# faad2 - AAC decoder (Git-based)

build_faad2() {
    local name="faad2"
    local srcdir="$BUILD_DIR/faad2"
    [[ -d "$srcdir" ]] && rm -rf "$srcdir"

    git clone https://github.com/dsvensson/faad2 "$srcdir"
    cd "$srcdir" || return 1
    ./bootstrap
    ./configure --prefix="$PREFIX" --enable-static --disable-shared || return 1
    safe_make || return 1
    make install || return 1

    cd "$TOOLKIT_ROOT" || true
    rm -rf "$srcdir"
    touch "${BUILD_DIR}/.done_${name}"
}
