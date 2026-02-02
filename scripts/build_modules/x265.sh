#!/usr/bin/env bash
# x265 - HEVC encoder (cmake)

build_x265() {
    local name="x265"
    if [[ "${FORCE_REBUILD:-0}" != "1" ]] && check_version_match "$name" 2>/dev/null; then
        log_info "[$name] Version matches, skipping"; return 0
    fi
    local version
    version=$(get_component_version "$name") || return 1
    local tarball="$DOWNLOADS_DIR/x265_${version}.tar.gz"
    [[ ! -f "$tarball" ]] && { log_error "Source not found: $tarball"; return 1; }

    mkdir -p "$BUILD_DIR"
    rm -rf "$BUILD_DIR/x265_"*
    tar xf "$tarball" -C "$BUILD_DIR" || return 1
    local extracted
    extracted=$(tar tf "$tarball" 2>/dev/null | head -1 | cut -d/ -f1)
    local srcdir="$BUILD_DIR/$extracted/source"
    [[ ! -d "$srcdir" ]] && srcdir="$BUILD_DIR/$extracted"
    mkdir -p "$srcdir/build" && cd "$srcdir/build" || return 1
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$PREFIX" -DENABLE_SHARED=OFF -DENABLE_CLI=ON
    safe_make || return 1
    make install || return 1

    _merge_pkgconfig_to_lib
    cd "$TOOLKIT_ROOT" || true
    rm -rf "$BUILD_DIR/$extracted"
    touch "${BUILD_DIR}/.done_${name}"
}
