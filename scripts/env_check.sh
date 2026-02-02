#!/usr/bin/env bash
# Hardware detection and OS identification
# Sets HAS_NVENC, HAS_QSV, etc. based on detected hardware
# Must be sourced after common.sh

# -----------------------------------------------------------------------------
# Hardware: NVIDIA GPU (NVENC/NVDEC)
# -----------------------------------------------------------------------------
HAS_NVENC=false
HAS_NVDEC=false
if command -v lspci &>/dev/null; then
    if lspci 2>/dev/null | grep -qi 'nvidia'; then
        HAS_NVENC=true
        HAS_NVDEC=true
    fi
fi
export HAS_NVENC HAS_NVDEC

# -----------------------------------------------------------------------------
# Hardware: Intel Quick Sync Video (QSV)
# Detected via /dev/dri (DRM) and Intel graphics in lspci
# -----------------------------------------------------------------------------
HAS_QSV=false
if [[ -d /dev/dri ]] && ([[ -e /dev/dri/card0 ]] || compgen -G /dev/dri/renderD* &>/dev/null); then
    if command -v lspci &>/dev/null && lspci 2>/dev/null | grep -qi 'intel.*graphics'; then
        HAS_QSV=true
    fi
fi
export HAS_QSV

# -----------------------------------------------------------------------------
# Hardware: AMD (AMF / VA-API)
# -----------------------------------------------------------------------------
HAS_AMF=false
HAS_VAAPI=false
if command -v lspci &>/dev/null; then
    if lspci 2>/dev/null | grep -qiE 'amd/ati|radeon'; then
        HAS_VAAPI=true
        HAS_AMF=true
    fi
fi
export HAS_AMF HAS_VAAPI

# -----------------------------------------------------------------------------
# OS identification
# -----------------------------------------------------------------------------
OS_FAMILY=""   # rhel | debian
OS_VERSION=""
DEP_PROVIDER=""  # dnf | apt

if [[ -f /etc/os-release ]]; then
    # shellcheck source=/dev/null
    source /etc/os-release
    case "${ID:-}" in
        rhel|centos|almalinux|rocky|fedora|ol)
            OS_FAMILY="rhel"
            OS_VERSION="${VERSION_ID:-}"
            DEP_PROVIDER="dnf"
            command -v dnf &>/dev/null || DEP_PROVIDER="yum"
            ;;
        ubuntu|debian)
            OS_FAMILY="debian"
            OS_VERSION="${VERSION_ID:-}"
            DEP_PROVIDER="apt"
            command -v apt &>/dev/null || DEP_PROVIDER="apt-get"
            ;;
        *)
            OS_FAMILY="${ID:-unknown}"
            OS_VERSION="${VERSION_ID:-}"
            if command -v dnf &>/dev/null; then
                DEP_PROVIDER="dnf"
            elif command -v apt &>/dev/null; then
                DEP_PROVIDER="apt"
            else
                DEP_PROVIDER=""
            fi
            ;;
    esac
fi
export OS_FAMILY OS_VERSION DEP_PROVIDER
