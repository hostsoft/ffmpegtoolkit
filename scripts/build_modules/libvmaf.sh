#!/usr/bin/env bash
# libvmaf - Netflix perceptual video quality assessment (meson)

build_libvmaf() {
    local name="libvmaf"
    local version
    version=$(get_component_version "$name") || return 1
    local tarball="$DOWNLOADS_DIR/vmaf-v${version}.tar.gz"
    [[ ! -f "$tarball" ]] && { log_error "Source not found: $tarball"; return 1; }

    mkdir -p "$BUILD_DIR"
    rm -rf "$BUILD_DIR/vmaf-"*
    tar xf "$tarball" -C "$BUILD_DIR" || return 1
    local extracted
    extracted=$(tar tf "$tarball" 2>/dev/null | head -1 | cut -d/ -f1)
    local blddir="$BUILD_DIR/libvmaf_build"
    mkdir -p "$blddir"
    cd "$blddir" || return 1

    meson setup "$BUILD_DIR/$extracted/libvmaf" --prefix="$PREFIX" --libdir="$PREFIX/lib" \
        -Ddefault_library=static -Denable_tests=false -Denable_docs=false
    ninja
    ninja install || return 1

    _merge_pkgconfig_to_lib
    cd "$TOOLKIT_ROOT" || true
    rm -rf "$BUILD_DIR/$extracted" "$blddir"
    touch "${BUILD_DIR}/.done_${name}"
}
