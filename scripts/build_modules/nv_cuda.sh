#!/usr/bin/env bash
# CUDA - optional, install from NVIDIA repo (for NVENC/NVDEC)
# Requires root. Skip if already installed.

build_nv_cuda() {
    local name="nv_cuda"
    if [[ -x "${CUDA_HOME:-/usr/local/cuda}/bin/nvcc" ]]; then
        log_info "[$name] CUDA already installed, skipping"; return 0
    fi
    if [[ "$OS_FAMILY" != "rhel" ]]; then
        log_warn "[$name] CUDA install only supported on RHEL/CentOS"; return 0
    fi
    log_info "[$name] Adding NVIDIA CUDA repo and installing..."
    $DEP_PROVIDER config-manager --add-repo http://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo 2>/dev/null || true
    $DEP_PROVIDER install -y cuda || log_warn "[$name] CUDA install failed (may need manual setup)"
    touch "${BUILD_DIR}/.done_${name}"
}
