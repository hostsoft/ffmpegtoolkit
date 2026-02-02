#!/usr/bin/env bash
# OpenH264 - Cisco royalty-free H.264 (make)

build_openh264() {
    local name="openh264"
    local version
    version=$(get_component_version "$name") || return 1
    local tarball="$DOWNLOADS_DIR/openh264-v${version}.tar.gz"
    [[ ! -f "$tarball" ]] && { log_error "Source not found: $tarball"; return 1; }

    mkdir -p "$BUILD_DIR"
    rm -rf "$BUILD_DIR/openh264-"*
    tar xf "$tarball" -C "$BUILD_DIR" || return 1
    local extracted
    extracted=$(tar tf "$tarball" 2>/dev/null | head -1 | cut -d/ -f1)
    cd "$BUILD_DIR/$extracted" || return 1

    safe_make || return 1
    make PREFIX="$PREFIX" install || return 1

    _merge_pkgconfig_to_lib
    cd "$TOOLKIT_ROOT" || true
    rm -rf "$BUILD_DIR/$extracted"
    touch "${BUILD_DIR}/.done_${name}"
}
