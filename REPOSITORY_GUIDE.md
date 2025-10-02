# Repository Structure - v1.0.2

**Last Updated:** October 2, 2025  
**Version:** 1.0.2 (Clean Release)

---

## 📂 Repository Layout

```
nfs-server/
├── Dockerfile                      # v1.0.2 Standard variant (62.8 MB)
├── Dockerfile.slim                 # v1.0.2-slim Slim variant (22.7 MB)
│
├── README.md                       # Main documentation
├── CHANGELOG.md                    # Version history
├── LICENSE                         # MIT License
│
├── RELEASE_NOTES_v1.0.0.md        # Initial release docs
├── RELEASE_NOTES_v1.0.1.md        # Security update docs
├── RELEASE_NOTES_v1.0.2.md        # Optimization release docs
├── OPTIMIZATION_GUIDE.md          # Optimization journey
├── v1.0.2_COMPLETE.md             # Release checklist
│
├── build-with-attestation.sh      # Build script with attestation
├── .dockerignore                  # Docker ignore rules
│
├── examples/
│   ├── deployment.yaml            # Kubernetes deployment
│   ├── deployment-with-pvc.yaml   # Deployment with PVC
│   ├── docker-compose.yaml        # Docker Compose example
│   ├── docker-compose.dev.yaml    # Development compose
│   └── ai-model-storage/          # AI/ML examples
│       ├── README.md
│       ├── jupyter-notebooks.yaml
│       ├── ollama-llama32-1b.yaml
│       └── pytorch-training.yaml
│
└── scripts/
    ├── deploy-llama32-1b.sh       # LLaMA deployment script
    └── manage-model-nfs.sh        # Model management script
```

---

## 📦 Docker Images

### Standard Version (Default)
- **File:** `Dockerfile`
- **Tag:** `boyroywax/nfs-server:1.0.2`
- **Size:** 62.8 MB
- **Features:** NFSv3/v4, Kerberos, Python tools
- **Packages:** 57

### Slim Variant (Lightweight)
- **File:** `Dockerfile.slim`
- **Tag:** `boyroywax/nfs-server:1.0.2-slim`
- **Size:** 22.7 MB
- **Features:** NFSv3 only (no v4, no Kerberos)
- **Packages:** 36

---

## 📚 Documentation Files

### Core Documentation
- **README.md** (11K)
  - Main project documentation
  - Quick start guide
  - Variant selection guide
  - Configuration options
  - Kubernetes deployment

### Version History
- **CHANGELOG.md** (4.9K)
  - All version changes
  - Version comparison
  - Feature additions/removals

### Release Notes
- **RELEASE_NOTES_v1.0.0.md** (4.8K) - Initial release
- **RELEASE_NOTES_v1.0.1.md** (4.7K) - Security update
- **RELEASE_NOTES_v1.0.2.md** (9.3K) - Optimization release

### Technical Guides
- **OPTIMIZATION_GUIDE.md** (8.7K)
  - Complete optimization journey
  - Size reduction techniques
  - Build process details
  - Multi-stage build explanation

- **v1.0.2_COMPLETE.md** (7.5K)
  - Release checklist
  - Build commands
  - Deployment steps
  - Next actions

---

## 🔧 Build & Deployment Files

### Build Scripts
- **build-with-attestation.sh**
  - Automated build with supply chain attestation
  - Supports both variants

### Docker Configuration
- **.dockerignore**
  - Files excluded from Docker build context

---

## 📁 Examples & Scripts

### Deployment Examples (`examples/`)
- **deployment.yaml** - Basic Kubernetes deployment
- **deployment-with-pvc.yaml** - With persistent volume claims
- **docker-compose.yaml** - Production Docker Compose
- **docker-compose.dev.yaml** - Development setup

### AI/ML Examples (`examples/ai-model-storage/`)
- **jupyter-notebooks.yaml** - Jupyter notebook storage
- **ollama-llama32-1b.yaml** - LLaMA model deployment
- **pytorch-training.yaml** - PyTorch training setup
- **README.md** - AI/ML use cases guide

### Helper Scripts (`scripts/`)
- **deploy-llama32-1b.sh** - Deploy LLaMA model
- **manage-model-nfs.sh** - Manage AI models on NFS

---

## 🎯 Quick Reference

### Building Images

```bash
# Standard (62.8 MB)
docker build -t boyroywax/nfs-server:1.0.2 .

# Slim (22.7 MB)
docker build -f Dockerfile.slim -t boyroywax/nfs-server:1.0.2-slim .
```

### Running

```bash
# Standard
docker run -d --privileged \
  -p 2049:2049 \
  boyroywax/nfs-server:1.0.2

# Slim
docker run -d --privileged \
  -p 2049:2049 \
  boyroywax/nfs-server:1.0.2-slim
```

### Documentation Map

| Want to... | Read this |
|------------|-----------|
| Get started quickly | README.md |
| See what changed | CHANGELOG.md |
| Understand v1.0.2 | RELEASE_NOTES_v1.0.2.md |
| Learn about optimization | OPTIMIZATION_GUIDE.md |
| Deploy to production | v1.0.2_COMPLETE.md |
| Use AI/ML storage | examples/ai-model-storage/README.md |

---

## ✨ Clean Repository

All temporary files, old documentation, and archived Dockerfiles have been removed. The repository contains only:
- ✅ Current version files (v1.0.2)
- ✅ Essential documentation
- ✅ Deployment examples
- ✅ Helper scripts

**Total files:** ~25 (down from 35+)

---

## 📞 Links

- **GitHub:** https://github.com/boyroywax/nfs-server
- **Docker Hub:** https://hub.docker.com/r/boyroywax/nfs-server
- **Issues:** https://github.com/boyroywax/nfs-server/issues

---

*Repository structure optimized for v1.0.2 release* 🚀
