#!/usr/bin/env bash
# libaom - AV1 (cmake, needs nasm)

build_aom() {
    local name="aom"
    local srcdir="$BUILD_DIR/aom"
    local blddir="$BUILD_DIR/aom_build"
    [[ -d "$srcdir" ]] && rm -rf "$srcdir" "$blddir"

    git clone --depth 1 https://aomedia.googlesource.com/aom "$srcdir"
    mkdir -p "$blddir"
    cd "$blddir" || return 1
    cmake "$srcdir" -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$PREFIX" \
        -DBUILD_SHARED_LIBS=OFF -DENABLE_NASM=ON
    safe_make || return 1
    make install || return 1

    cd "$TOOLKIT_ROOT" || true
    rm -rf "$srcdir" "$blddir"
    touch "${BUILD_DIR}/.done_${name}"
}
