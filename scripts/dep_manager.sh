#!/usr/bin/env bash
# Dependency manager: CRB/PowerTools, build tools (gcc, cmake, meson, ninja, python3)
# Must be sourced after common.sh and env_check.sh

# -----------------------------------------------------------------------------
# Enable EPEL for RHEL/CentOS/Alma/Rocky (provides meson, ninja-build, etc.)
# -----------------------------------------------------------------------------
enable_epel() {
    [[ "$OS_FAMILY" != "rhel" ]] && return 0
    [[ -z "$DEP_PROVIDER" ]] && return 0
    # Check if EPEL is already enabled (epel-release or epel.repo present)
    if rpm -q epel-release &>/dev/null || [[ -f /etc/yum.repos.d/epel.repo ]] 2>/dev/null; then
        return 0
    fi
    log_info "Installing EPEL repository..."
    local ver="${OS_VERSION%%.*}"
    case "$ver" in
        8) $DEP_PROVIDER install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm 2>/dev/null || $DEP_PROVIDER install -y epel-release ;;
        9) $DEP_PROVIDER install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm 2>/dev/null || $DEP_PROVIDER install -y epel-release ;;
        *) $DEP_PROVIDER install -y epel-release 2>/dev/null || true ;;
    esac
}

# -----------------------------------------------------------------------------
# Enable CRB (Code Ready Builder) / PowerTools repo for RHEL/CentOS/Alma/Rocky
# RHEL 8: powertools | RHEL 9/10: crb
# -----------------------------------------------------------------------------
enable_crb_powertools() {
    [[ "$OS_FAMILY" != "rhel" ]] && return 0
    [[ -z "$DEP_PROVIDER" ]] && { log_warn "DEP_PROVIDER not set, skip CRB/PowerTools"; return 0; }

    local ver="${OS_VERSION%%.*}"
    if [[ "$ver" -eq 8 ]] 2>/dev/null; then
        log_info "Enabling PowerTools (RHEL 8)..."
        $DEP_PROVIDER config-manager --set-enabled powertools 2>/dev/null || \
        $DEP_PROVIDER config-manager --set-enabled PowerTools 2>/dev/null || \
        log_warn "PowerTools enable failed (may need root)"
    elif [[ "$ver" -ge 9 ]] 2>/dev/null; then
        log_info "Enabling CRB (RHEL 9+)..."
        $DEP_PROVIDER config-manager --set-enabled crb 2>/dev/null || \
        log_warn "CRB enable failed (may need root)"
    fi
}

# -----------------------------------------------------------------------------
# Install build dependencies (gcc, cmake, meson, ninja, python3, etc.)
# -----------------------------------------------------------------------------
install_build_deps() {
    if [[ "$OS_FAMILY" == "rhel" ]]; then
        _install_build_deps_rhel
    elif [[ "$OS_FAMILY" == "debian" ]]; then
        _install_build_deps_debian
    else
        log_warn "Unknown OS family, skipping build deps install"
    fi
}

_install_build_deps_rhel() {
    enable_crb_powertools
    enable_epel
    # To ensure EPEL repo is properly loaded, update dnf cache after enabling EPEL
    if [[ "$DEP_PROVIDER" == "dnf" ]]; then
        log_info "Updating dnf cache after enabling EPEL..."
        $DEP_PROVIDER makecache || $DEP_PROVIDER update -y
    fi
    local pkgs=(
        gcc gcc-c++ make git unzip lbzip2 sudo wget xz tar diffutils
        cmake cmake3 meson ninja-build
        automake autoconf libtool pkgconfig
        nasm yasm
        zlib-devel openssl-devel
        libxml2-devel freetype-devel fribidi-devel harfbuzz-devel fontconfig-devel
        libpng-devel libjpeg-turbo-devel libtiff-devel libwebp-devel
        mediainfo libmediainfo libmediainfo-devel
        ImageMagick ImageMagick-devel
        python3 python3-pip
    )
    for p in "${pkgs[@]}"; do
        if $DEP_PROVIDER list installed "$p" &>/dev/null; then
            log_info "[skip] $p already installed"
        else
            log_info "Installing $p..."
            $DEP_PROVIDER install -y "$p" || log_warn "Failed to install $p"
        fi
    done
    # meson & ninja via pip if dnf packages failed (ensure ~/.local/bin in PATH)
    export PATH="${HOME:-/root}/.local/bin:$PATH"
    if ! command -v meson &>/dev/null; then
        log_info "Installing meson via pip..."
        (python3 -m pip install --user meson 2>/dev/null || pip3 install --user meson 2>/dev/null || python3 -m pip install meson 2>/dev/null) || log_warn "meson pip install failed"
    fi
    if ! command -v ninja &>/dev/null; then
        log_info "Installing ninja via pip..."
        (python3 -m pip install --user ninja 2>/dev/null || pip3 install --user ninja 2>/dev/null || python3 -m pip install ninja 2>/dev/null) || log_warn "ninja pip install failed"
    fi
}

_install_build_deps_debian() {
    local pkgs=(
        build-essential gcc g++ make git wget xz-utils tar
        cmake automake autoconf libtool pkg-config
        nasm yasm zlib1g-dev libssl-dev
        libxml2-dev libfreetype-dev libfribidi-dev libharfbuzz-dev libfontconfig1-dev
        libpng-dev libjpeg-dev libtiff-dev libwebp-dev
        mediainfo libmediainfo-dev
        imagemagick libmagickwand-dev
        python3 python3-pip meson ninja-build
    )
    log_info "Installing build dependencies..."
    $DEP_PROVIDER update -qq
    $DEP_PROVIDER install -y "${pkgs[@]}" || log_warn "Some packages may have failed"
}
