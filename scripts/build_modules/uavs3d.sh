#!/usr/bin/env bash
# uavs3d - AVS3 decoder (Git-based)

build_uavs3d() {
    local name="uavs3d"
    local srcdir="$BUILD_DIR/uavs3d"
    [[ -d "$srcdir" ]] && rm -rf "$srcdir"

    git clone https://github.com/uavs3/uavs3d "$srcdir"
    mkdir -p "$srcdir/build/linux"
    cd "$srcdir/build/linux" || return 1
    cmake ../.. -DCMAKE_INSTALL_PREFIX="$PREFIX"
    safe_make || return 1
    make install || return 1

    cd "$TOOLKIT_ROOT" || true
    rm -rf "$srcdir"
    touch "${BUILD_DIR}/.done_${name}"
}
