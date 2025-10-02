# NFS Server v1.0.1 - Docker Image Optimization Analysis

**Current Image Size:** 68.6 MB  
**Analysis Date:** October 2, 2025  
**Base Image:** Alpine Linux 3.22

## Current Package Inventory

### Core Required Packages (Essential for NFS)
✅ **Must Keep:**
- `nfs-utils` (2.6.4-r4) - Core NFS server functionality
- `rpcbind` (1.2.7-r0) - RPC service binding (required by NFS)
- `libtirpc` + `libtirpc-conf` - RPC implementation (NFS dependency)
- `libnfsidmap` - NFS ID mapping (NFS dependency)
- `openssl` (3.5.4-r0) - Security/crypto (required, CVE fixed)
- `expat` (2.7.3-r0) - XML parsing (required, CVE fixed)
- `krb5-libs` + `krb5-conf` - Kerberos support (NFS dependency)
- `keyutils-libs` - Kernel key management (NFS dependency)
- `device-mapper-libs` - Device mapping (NFS dependency)
- `libevent` - Event handling (RPC dependency)
- `libblkid`, `libmount`, `libuuid` - Disk/mount utilities (NFS dependencies)
- `sqlite-libs` - SQLite support (NFS dependency)

### Python Installation (QUESTIONABLE)
⚠️ **Can Potentially Remove:**
- `python3` (3.12.11-r0) - **~15-20 MB**
- `python3-pyc` (3.12.11-r0)
- `python3-pycache-pyc0` (3.12.11-r0)
- `pyc` (3.12.11-r0)
- `mpdecimal` (4.0.1-r0) - Python dependency
- `gdbm` (1.24-r0) - Python dependency
- `libffi` (3.4.8-r0) - Python dependency
- `sqlite-libs` (3.49.2-r1) - Shared with NFS, but Python also uses it

**Analysis:** Python3 is listed as a dependency of `nfs-utils`, but this may not be strictly necessary for basic NFS operations. Need to verify if any NFS utilities actually require Python.

### Bash Shell
⚠️ **Can Replace with Busybox sh:**
- `bash` (5.2.37-r0) - **~1.5 MB**
- `readline` (8.2.13-r1) - Bash dependency

**Analysis:** The startup scripts use `#!/bin/bash` but could be rewritten to use POSIX-compliant `/bin/sh` (busybox). This would save space and reduce dependencies.

### util-linux Package Suite
⚠️ **Many Utilities Unnecessary:**
- `util-linux` (meta-package)
- `util-linux-misc` - Collection of utilities
- `agetty` - Terminal/TTY management ❌ **NOT needed in container**
- `blkid` - Block device identification (used by NFS)
- `cfdisk` - Disk partitioning tool ❌ **NOT needed in container**
- `dmesg` - Kernel message viewer ❌ **NOT needed for NFS**
- `findmnt` - Find mounted filesystems (useful for debugging)
- `flock` - File locking utility ❌ **NOT needed**
- `fstrim` - SSD trim utility ❌ **NOT needed in container**
- `hexdump` - Hex viewer ❌ **NOT needed**
- `logger` - System logging ❌ **NOT needed**
- `losetup` - Loop device setup ❌ **NOT needed**
- `lsblk` - List block devices ❌ **NOT needed**
- `lscpu` - CPU information ❌ **NOT needed**
- `mcookie` - Generate cookies ❌ **NOT needed**
- `mount`/`umount` - Mount utilities (needed for NFS export checks)
- `partx` - Partition tool ❌ **NOT needed**
- `runuser` - Run commands as user ❌ **NOT needed**
- `setarch` - Set architecture ❌ **NOT needed**
- `setpriv` - Set privileges ❌ **NOT needed**
- `sfdisk` - Disk partitioning ❌ **NOT needed**
- `uuidgen` - UUID generation ❌ **NOT needed**
- `wipefs` - Wipe filesystem signatures ❌ **NOT needed**

**Estimated Savings:** ~5-8 MB by removing unnecessary util-linux tools

### Base System Packages
✅ **Must Keep:**
- `alpine-baselayout` + `alpine-baselayout-data`
- `alpine-keys` - Package verification
- `alpine-release`
- `apk-tools` - Package management
- `busybox` + `busybox-binsh` - Core utilities
- `ca-certificates-bundle` - SSL certificates
- `musl` + `musl-utils` - C library
- `ncurses-terminfo-base` + `libncursesw` - Terminal support
- `ssl_client` - SSL/TLS client
- `zlib` - Compression library
- `xz-libs` - Compression library
- `libbz2` - Compression library

### Other Packages
- `linux-pam` (1.7.0-r4) - PAM authentication (may be needed for NFS auth)
- `libeconf` (0.6.3-r0) - Config file parsing
- `skalibs-libs` - System libraries
- `utmps-libs` - User login tracking ❌ **NOT needed in container**
- `scanelf` - ELF scanner (build/debug tool) ❌ **NOT needed at runtime**
- `libcap2` + `libcap-ng` - Capabilities (needed for privilege management)

## Optimization Recommendations

### Level 1: Safe Removals (Est. 8-12 MB savings)
Remove packages that are clearly unnecessary in a containerized NFS server:

1. **Remove disk partitioning tools:**
   - `cfdisk`, `sfdisk`, `partx`, `wipefs`

2. **Remove system info tools:**
   - `lscpu`, `dmesg`, `hexdump`

3. **Remove unnecessary utilities:**
   - `agetty`, `fstrim`, `flock`, `uuidgen`, `logger`, `mcookie`
   - `runuser`, `setarch`, `setpriv`
   - `losetup`, `lsblk` (if not used in scripts)
   - `utmps-libs`, `scanelf`

### Level 2: Moderate Changes (Est. 15-20 MB savings)
Requires script modifications:

1. **Replace Bash with Busybox sh:**
   - Rewrite `/usr/local/bin/configure-exports.sh` to be POSIX compliant
   - Rewrite `/usr/local/bin/start-nfs.sh` to be POSIX compliant
   - Remove `bash` and `readline` packages
   - **Savings:** ~1.5 MB

2. **Install only required util-linux components:**
   - Instead of full `util-linux` package, install only:
     - `mount`, `umount`, `blkid`, `findmnt`
   - **Savings:** ~3-5 MB

### Level 3: Investigate Python Requirement (Est. 15-20 MB savings)
**High Risk - Requires Testing:**

1. **Verify Python necessity:**
   - Check if NFS utilities actually execute Python scripts
   - Test NFS functionality without Python installed
   - If Python is truly needed, identify which specific scripts require it

2. **Potential approaches:**
   - Build `nfs-utils` without Python support (compile from source)
   - Find alternative NFS implementation without Python dependency
   - **Savings:** ~15-20 MB if Python can be removed

### Level 4: Multi-Stage Build (Est. 5-10 MB additional savings)
Create a multi-stage Dockerfile:

1. Build stage: Compile/configure with all tools
2. Runtime stage: Copy only necessary binaries and libraries
3. Strip debug symbols from binaries

## Proposed Optimized Dockerfile Structure

```dockerfile
# Stage 1: Builder (if needed for custom compilation)
FROM alpine:3.22 AS builder
# ... build steps if needed ...

# Stage 2: Runtime
FROM alpine:3.22

# Install ONLY essential packages
RUN apk update && apk upgrade && \
    apk add --no-cache \
    'openssl>=3.5.4-r0' \
    'expat>=2.7.2-r0' \
    nfs-utils \
    rpcbind \
    # Only install specific util-linux components
    mount \
    umount \
    blkid \
    findmnt \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*

# ... rest of configuration ...
```

## Testing Requirements

Before implementing optimizations, test:

1. ✅ NFS mount/export functionality
2. ✅ Multi-client access
3. ✅ Health checks work correctly
4. ✅ Graceful shutdown
5. ✅ Permission management
6. ✅ Kerberos authentication (if used)

## Size Reduction Targets

| Optimization Level | Est. Final Size | Reduction | Risk |
|-------------------|-----------------|-----------|------|
| Current | 68.6 MB | - | - |
| Level 1 (Safe) | 56-60 MB | 8-12 MB | Low |
| Level 1+2 (Moderate) | 41-48 MB | 20-27 MB | Medium |
| Level 1+2+3 (Aggressive) | 26-33 MB | 35-42 MB | High |
| Level 1+2+3+4 (Maximum) | 21-28 MB | 40-47 MB | High |

## Immediate Action Items

1. ✅ Verify Python requirement for nfs-utils
2. ✅ Test NFS functionality with minimal util-linux
3. ✅ Rewrite shell scripts to be POSIX compliant
4. ✅ Create optimized Dockerfile variant
5. ✅ Run comprehensive tests
6. ✅ Update documentation

## Notes

- Alpine Linux is already minimal, so significant reductions require careful analysis
- Any package removal must be tested thoroughly
- Consider creating both "standard" and "minimal" image variants
- Document any functionality trade-offs clearly
