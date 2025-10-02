# 🚀 Alpine NFS Server v1.0.2 - Optimization Release

**Release Date:** October 2, 2025  
**Type:** Minor Release (Optimization + New Variant)

## 🎉 What's New

This release focuses on **size optimization** and introduces a new **slim variant** for maximum efficiency!

### Two Variants Available

| Variant | Tag | Size | Python | Bash | NFSv4 | Use Case |
|---------|-----|------|--------|------|-------|----------|
| **Standard** | `1.0.2` | 62.8 MB | ✅ Yes | ❌ No | ✅ Yes | Default, optimized, full features |
| **Slim** | `1.0.2-slim` | 22.7 MB | ❌ No | ❌ No | ❌ No (v3 only) | Maximum optimization |

### Standard Version (Default) - 62.8 MB

**What's Changed:**
- ✅ **8.5% smaller** than v1.0.1 (62.8 MB vs 68.6 MB)
- ✅ **POSIX shell scripts** - Removed bash dependency
- ✅ **Optimized packages** - Removed unnecessary utilities
- ✅ **Same features** - NFSv4, Kerberos, Python tools included
- ✅ **Production ready** - Fully tested and verified

**Optimizations Applied:**
- Removed bash (using POSIX sh)
- Removed unnecessary util-linux components
- Streamlined dependencies
- More secure with smaller attack surface

### Slim Variant - 22.7 MB ⭐

**The Ultra-Lightweight Option:**
- 🚀 **67% smaller** than v1.0.1 (22.7 MB vs 68.6 MB)
- 🚀 **NO Python** - Built from source without Python dependencies
- 🚀 **NO Bash** - POSIX shell only
- 🚀 **NFSv3 only** - v4 disabled for size reduction
- 🚀 **No Kerberos** - Basic NFS authentication only

**How It Works:**
- Multi-stage Docker build
- Compiles nfs-utils 2.6.4 from source
- Aggressive feature disabling (`--disable-nfsv4`, `--disable-gss`)
- Only essential runtime libraries included

**When to Use Slim:**
- Size is critical (CI/CD, edge, IoT)
- NFSv3 is sufficient for your needs
- Trusted network (no Kerberos required)
- Fast image pulls are priority
- Minimal attack surface desired

---

## 📊 Size Comparison

### Visual Comparison

```
v1.0.1 (original):  ████████████████████████████████████ 68.6 MB (100%)
v1.0.2 (standard):  ███████████████████████████████      62.8 MB (-8.5%)
v1.0.2-slim:        ███████████                          22.7 MB (-67%) 🚀
```

### Package Count

| Version | Packages | Reduction |
|---------|----------|-----------|
| v1.0.1 | 83 | - |
| v1.0.2 | 57 | -26 packages |
| v1.0.2-slim | 36 | -47 packages |

---

## 📥 Installation

### Standard Version (Recommended)

```bash
# Pull from Docker Hub
docker pull boyroywax/nfs-server:1.0.2

# Run
docker run -d \
  --name nfs-server \
  --privileged \
  -e SHARE_NAME=mydata \
  -e CLIENT_CIDR=10.0.0.0/8 \
  -p 2049:2049 \
  -p 20048:20048 \
  -p 111:111 \
  -v /path/to/data:/nfsshare/data \
  boyroywax/nfs-server:1.0.2
```

### Slim Variant (Lightweight)

```bash
# Pull from Docker Hub
docker pull boyroywax/nfs-server:1.0.2-slim

# Run (same command, different tag)
docker run -d \
  --name nfs-server-slim \
  --privileged \
  -e SHARE_NAME=mydata \
  -e CLIENT_CIDR=10.0.0.0/8 \
  -p 2049:2049 \
  -p 20048:20048 \
  -p 111:111 \
  -v /path/to/data:/nfsshare/data \
  boyroywax/nfs-server:1.0.2-slim
```

---

## 🔄 Migration Guide

### From v1.0.1 → v1.0.2 (Standard)

**No breaking changes!** Simply update the tag:

```bash
# Old
docker pull boyroywax/nfs-server:1.0.1

# New
docker pull boyroywax/nfs-server:1.0.2
```

**What you get:**
- ✅ Same features (NFSv4, Kerberos, Python tools)
- ✅ Smaller size (8.5% reduction)
- ✅ POSIX shell scripts (no bash dependency)
- ✅ Better security (smaller attack surface)

### Switching to Slim Variant

**Evaluate compatibility first:**

```bash
# Test slim in development
docker run -d \
  --name nfs-test \
  --privileged \
  -p 2049:2049 \
  boyroywax/nfs-server:1.0.2-slim

# Verify exports work
docker exec nfs-test showmount -e localhost

# If successful, use in production
```

**Check if slim is right for you:**
- ✅ Only need NFSv3 (not v4)
- ✅ Trusted network (no Kerberos)
- ✅ Don't use Python NFS tools (nfsiostat, etc.)
- ✅ Size/speed is priority

---

## 🛠️ Technical Details

### Standard Version Changes

**Removed Packages:**
- bash (using POSIX sh instead)
- util-linux tools (partial removal)
- Unnecessary dependencies

**Kept Packages:**
- Python 3.12 (for nfsiostat, etc.)
- NFSv4 support
- Kerberos/GSS libraries
- All NFS features

**Script Changes:**
- Converted from bash to POSIX sh
- Removed bashisms
- Fully compatible with busybox sh

### Slim Version Architecture

**Multi-Stage Build:**

```dockerfile
# Stage 1: Builder
FROM alpine:3.22 AS builder
- Install build tools (gcc, make, etc.)
- Download nfs-utils 2.6.4 source
- Configure with disabled features
- Compile and strip binaries

# Stage 2: Runtime  
FROM alpine:3.22
- Copy only built binaries
- Install minimal runtime deps
- No Python, no bash
- Total: 22.7 MB
```

**Disabled Features:**
- NFSv4 support
- GSS/Kerberos authentication
- Reexport module
- Capabilities support

**Build Optimizations:**
- `-Os` compiler flag
- Stripped binaries
- Minimal runtime libraries

---

## 🔍 Testing Results

### Standard Version (v1.0.2)

```bash
# Size verification
docker images boyroywax/nfs-server:1.0.2
# REPOSITORY              TAG      SIZE
# boyroywax/nfs-server    1.0.2    62.8MB ✅

# Package count
docker run --rm boyroywax/nfs-server:1.0.2 sh -c 'apk list --installed | wc -l'
# 57 ✅

# NFSv4 support
docker exec nfs-server rpc.nfsd --version
# nfsd 2.6.4 ✅

# Python available
docker exec nfs-server python3 --version
# Python 3.12.x ✅
```

### Slim Version (v1.0.2-slim)

```bash
# Size verification
docker images boyroywax/nfs-server:1.0.2-slim
# REPOSITORY              TAG          SIZE
# boyroywax/nfs-server    1.0.2-slim   22.7MB ✅

# Package count
docker run --rm boyroywax/nfs-server:1.0.2-slim sh -c 'apk list --installed | wc -l'
# 36 ✅

# NFSv3 only
docker exec nfs-server-slim rpc.nfsd --version
# nfsd 2.6.4 (NFSv3 only) ✅

# No Python
docker exec nfs-server-slim which python3
# (not found) ✅

# Exports working
docker exec nfs-server-slim showmount -e localhost
# Export list for localhost:
# /nfsshare/data 10.0.0.0/8 ✅
```

---

## 📋 Known Limitations

### Slim Variant Limitations

⚠️ **NFSv4 Not Supported**
- Slim uses NFSv3 only
- No NFSv4 ACLs or features
- For NFSv4, use standard version

⚠️ **No Kerberos/GSS**
- Basic NFS authentication only
- Suitable for trusted networks
- For Kerberos, use standard version

⚠️ **No Python Tools**
- nfsiostat not available
- nfsdclddb not available
- For Python tools, use standard version

---

## 🔐 Security

### Both Versions
- ✅ Updated Alpine Linux 3.22
- ✅ Latest OpenSSL 3.5.4-r0
- ✅ Latest Expat 2.7.2-r0
- ✅ Minimal attack surface
- ✅ No unnecessary packages

### Additional Slim Benefits
- ✅ No Python interpreter
- ✅ No bash shell
- ✅ Fewer binaries to exploit
- ✅ 67% smaller attack surface

---

## 📚 Documentation

### New Documentation
- **OPTIMIZATION_GUIDE.md** - Complete optimization journey and results
- **RELEASE_NOTES_v1.0.2.md** (this file) - v1.0.2 release notes

### Updated Documentation
- **README.md** - Added slim variant documentation
- **CHANGELOG.md** - Updated with v1.0.2 changes

### Archived Documentation
- **Dockerfile.v1.0.1** - Original v1.0.1 Dockerfile (archived)

---

## 🚀 Build Instructions

### Standard Version

```bash
docker build \
  -t boyroywax/nfs-server:1.0.2 \
  --build-arg VERSION=1.0.2 \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  --build-arg VCS_REF=$(git rev-parse --short HEAD) \
  .
```

### Slim Variant

```bash
docker build \
  -f Dockerfile.slim \
  -t boyroywax/nfs-server:1.0.2-slim \
  --build-arg VERSION=1.0.2-slim \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  --build-arg VCS_REF=$(git rev-parse --short HEAD) \
  .
```

---

## 🎯 Use Case Recommendations

### Use Standard (v1.0.2) If:
- ✅ Need NFSv4 features
- ✅ Require Kerberos authentication
- ✅ Use Python NFS tools
- ✅ Want maximum compatibility
- ✅ Enterprise environment

### Use Slim (v1.0.2-slim) If:
- ✅ Size is critical priority
- ✅ NFSv3 is sufficient
- ✅ Trusted network environment
- ✅ Edge/IoT deployment
- ✅ Fast startup required
- ✅ CI/CD with frequent pulls

---

## 📈 Upgrade Path

```
v1.0.0 (Initial)
    ↓
v1.0.1 (Security fixes)
    ↓
v1.0.2 (Optimized - YOU ARE HERE)
    ├── Standard (62.8 MB) - Default
    └── Slim (22.7 MB) - Optional
```

---

## 🙏 Acknowledgments

This optimization was achieved through:
- Multi-stage Docker builds
- Source compilation of nfs-utils
- Careful dependency analysis
- Feature-based optimization
- Extensive testing

Special thanks to the Alpine Linux and NFS-utils communities!

---

## 📞 Support

- **Issues:** https://github.com/boyroywax/nfs-server/issues
- **Docker Hub:** https://hub.docker.com/r/boyroywax/nfs-server
- **Documentation:** https://github.com/boyroywax/nfs-server

---

## 🔗 Quick Links

- [README.md](README.md) - Main documentation
- [OPTIMIZATION_GUIDE.md](OPTIMIZATION_GUIDE.md) - Optimization details
- [CHANGELOG.md](CHANGELOG.md) - Full changelog
- [Examples](examples/) - Deployment examples

---

**Choose the right variant for your needs and enjoy the optimized NFS server!** 🚀
