#!/usr/bin/env bash
# libjxl - JPEG XL image codec (git clone with bundled highway, brotli, skcms)

build_libjxl() {
    local name="libjxl"
    local repo_url="https://github.com/libjxl/libjxl.git"
    local version
    version=$(get_component_version "$name") || version="main"
    local repo_dir="$DOWNLOADS_DIR/libjxl_repo"

    log_info "Starting Git-based build for libjxl (with all submodules)..."

    mkdir -p "$DOWNLOADS_DIR"
    cd "$DOWNLOADS_DIR" || return 1

    if [[ ! -d "$repo_dir" ]]; then
        log_info "Cloning libjxl repository (--recursive)..."
        git clone --recurse-submodules "$repo_url" libjxl_repo || return 1
        cd libjxl_repo || return 1
        git submodule update --init --recursive
        # Checkout requested version
        git checkout "v${version}" 2>/dev/null || git checkout "${version}" 2>/dev/null || true
        git submodule update --init --recursive --force || return 1
    else
        log_info "Using existing libjxl repository (offline/skip clone)..."
        cd libjxl_repo || return 1
        git fetch --all 2>/dev/null || true
        git checkout "v${version}" 2>/dev/null || git checkout "${version}" 2>/dev/null || git checkout main 2>/dev/null || true
        log_info "Syncing submodules (highway, brotli, skcms)..."
        git submodule update --init --recursive --force || return 1
    fi

    local srcdir="$DOWNLOADS_DIR/libjxl_repo"
    local blddir="$BUILD_DIR/libjxl_build"
    rm -rf "$blddir"
    mkdir -p "$blddir"
    cd "$blddir" || return 1

    cmake "$srcdir" -G "Unix Makefiles" \
        -DCMAKE_INSTALL_PREFIX="$PREFIX" \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DBUILD_TESTING=OFF \
        -DJPEGXL_ENABLE_TOOLS=OFF \
        -DJPEGXL_ENABLE_TESTS=OFF \
        -DJPEGXL_ENABLE_BENCHMARK=OFF \
        -DJPEGXL_ENABLE_EXAMPLES=OFF \
        -DJPEGXL_ENABLE_SKCMS=ON \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON

    safe_make || return 1
    make install || return 1

    _merge_pkgconfig_to_lib
    cd "$TOOLKIT_ROOT" || true
    touch "${BUILD_DIR}/.done_${name}"
    log_info "libjxl build completed (using bundled highway, brotli, skcms)."
}
