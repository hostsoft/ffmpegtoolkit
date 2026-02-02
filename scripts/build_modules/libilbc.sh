#!/usr/bin/env bash
# libilbc - iLBC VoIP codec (cmake, requires abseil submodule)

build_libilbc() {
    local name="libilbc"
    local srcdir="$BUILD_DIR/libilbc"
    local blddir="$BUILD_DIR/libilbc_build"
    [[ -d "$srcdir" ]] && rm -rf "$srcdir" "$blddir"

    git clone --depth 1 --recurse-submodules https://github.com/TimothyGu/libilbc.git "$srcdir"
    cd "$srcdir" || return 1
    git submodule update --init --recursive
    mkdir -p "$blddir"
    cd "$blddir" || return 1

    cmake "$srcdir" -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$PREFIX" \
        -DBUILD_SHARED_LIBS=OFF
    safe_make || return 1
    make install || return 1

    cd "$TOOLKIT_ROOT" || true
    rm -rf "$srcdir" "$blddir"
    touch "${BUILD_DIR}/.done_${name}"
}
