#!/usr/bin/env bash
# libwebp build module
# Flow: unpack -> configure -> make -> make install -> clean
# Must be sourced after common.sh (TOOLKIT_ROOT, PREFIX, BUILD_DIR, DOWNLOADS_DIR)

build_libwebp() {
    local name="libwebp"
    if [[ "${FORCE_REBUILD:-0}" != "1" ]] && check_version_match "$name" 2>/dev/null; then
        log_info "[$name] Version matches, skipping build"
        return 0
    fi
    local version
    version=$(get_component_version "$name") || { log_error "Cannot get version for $name"; return 1; }
    local archive
    archive=$(get_component_archive "$name" "$version") || { log_error "Cannot get archive for $name"; return 1; }
    local tarball="$DOWNLOADS_DIR/$archive"

    [[ ! -f "$tarball" ]] && { log_error "Source not found: $tarball (run ./build.sh fetch)"; return 1; }

    # -------------------------------------------------------------------------
    # Unpack
    # -------------------------------------------------------------------------
    log_info "[$name] Unpacking $archive ..."
    mkdir -p "$BUILD_DIR"
    rm -rf "$BUILD_DIR/libwebp-"*
    tar xf "$tarball" -C "$BUILD_DIR" || { log_error "[$name] Unpack failed"; return 1; }
    local extracted
    extracted=$(tar tf "$tarball" 2>/dev/null | head -1 | cut -d/ -f1)
    cd "$BUILD_DIR/$extracted" || return 1

    # -------------------------------------------------------------------------
    # Configure (static build)
    # -------------------------------------------------------------------------
    log_info "[$name] Configuring ..."
    ./configure \
        --prefix="$PREFIX" \
        --enable-static \
        --disable-shared \
        || { log_error "[$name] Configure failed"; return 1; }

    # -------------------------------------------------------------------------
    # Make
    # -------------------------------------------------------------------------
    log_info "[$name] Building ..."
    safe_make || return 1

    # -------------------------------------------------------------------------
    # Make install
    # -------------------------------------------------------------------------
    log_info "[$name] Installing to $PREFIX ..."
    make install || { log_error "[$name] Install failed"; return 1; }

    _merge_pkgconfig_to_lib
    # -------------------------------------------------------------------------
    # Clean
    # -------------------------------------------------------------------------
    log_info "[$name] Cleaning build dir ..."
    cd "$TOOLKIT_ROOT" || true
    rm -rf "$BUILD_DIR/$extracted"

    touch "${BUILD_DIR}/.done_${name}"
    log_info "[$name] Build completed."
}
