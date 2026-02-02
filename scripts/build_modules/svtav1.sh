#!/usr/bin/env bash
# SVT-AV1 - Intel Scalable Video Technology AV1 encoder (cmake, needs nasm)

build_svtav1() {
    local name="svtav1"
    local version
    version=$(get_component_version "$name") || return 1
    local tarball="$DOWNLOADS_DIR/SVT-AV1-v${version}.tar.gz"
    [[ ! -f "$tarball" ]] && { log_error "Source not found: $tarball"; return 1; }

    mkdir -p "$BUILD_DIR"
    rm -rf "$BUILD_DIR/SVT-AV1-"*
    tar xf "$tarball" -C "$BUILD_DIR" || return 1
    local extracted
    extracted=$(tar tf "$tarball" 2>/dev/null | head -1 | cut -d/ -f1)
    local blddir="$BUILD_DIR/svtav1_build"
    mkdir -p "$blddir"
    cd "$blddir" || return 1

    cmake "$BUILD_DIR/$extracted" -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$PREFIX" \
        -DBUILD_SHARED_LIBS=OFF -DBUILD_APPS=OFF -DBUILD_DEC=OFF -DENABLE_NASM=ON
    safe_make || return 1
    make install || return 1

    _merge_pkgconfig_to_lib
    cd "$TOOLKIT_ROOT" || true
    rm -rf "$BUILD_DIR/$extracted" "$blddir"
    touch "${BUILD_DIR}/.done_${name}"
}
