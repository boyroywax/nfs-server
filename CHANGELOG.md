# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2025-10-02

### Added
- **Slim Variant** - New ultra-lightweight variant at 22.7 MB (67% smaller than v1.0.1)
- **Multi-Variant Support** - Two optimized variants: Standard (62.8 MB) and Slim (22.7 MB)
- **Source-Compiled NFS** - Slim variant compiles nfs-utils from source without Python
- **OPTIMIZATION_GUIDE.md** - Complete optimization documentation and analysis

### Changed
- **Standard Version Optimized** - Reduced from 68.6 MB to 62.8 MB (8.5% reduction)
- **POSIX Shell Scripts** - Removed bash dependency, using POSIX sh for better compatibility
- **Package Reduction** - Removed 26 unnecessary packages from standard version
- Base image: `alpine:3.22` (continues from v1.0.1)
- Docker images: 
  - `boyroywax/nfs-server:1.0.2` (standard, 62.8 MB)
  - `boyroywax/nfs-server:1.0.2-slim` (lightweight, 22.7 MB)

### Removed (Standard Version)
- bash shell (using POSIX sh)
- Unnecessary util-linux components
- 26 redundant packages

### Removed (Slim Variant)
- Python 3.12 (~30 MB saved)
- NFSv4 support (NFSv3 only)
- Kerberos/GSS authentication
- bash shell
- 47 total packages removed vs v1.0.1

### Technical Details (Slim)
- Multi-stage Docker build
- nfs-utils 2.6.4 compiled from source
- Build flags: `--disable-nfsv4 --disable-gss --disable-reexport`
- Only 36 packages in final image

## [1.0.1] - 2025-10-02

### Security
- **Alpine Base Image Update** - Updated from Alpine Linux 3.22.1 to 3.22 (latest) to address OpenSSL security vulnerabilities
- **OpenSSL Security Patch** - Explicitly upgraded openssl to version 3.5.4-r0 to resolve CVE-2025-9230 (CVSS 7.5)
- **Expat Security Patch** - Explicitly upgraded expat to version 2.7.2-r0 to resolve CVE-2025-59375 (CVSS 7.5)
- **CVE Resolution** - Resolves multiple high-severity CVEs in openssl and expat packages

### Changed
- Base image: `alpine:3.22` (from 3.22.1, now tracks latest 3.22.x)
- Docker image: `boyroywax/nfs-server:1.0.1`
- Package updates: openssl>=3.5.4-r0, expat>=2.7.2-r0

## [1.0.0] - 2024-12-28

### Added
- **Production-Ready NFS Server** - Alpine Linux 3.22.1 based NFS server container
- **Docker Hub Image** - Published as `boyroywax/nfs-server:1.0.0` with full attestation and SBOM
- **Kubernetes Native** - Complete Kubernetes deployment manifests with health checks
- **AI/ML Optimized** - Specialized examples for model storage and training workloads
- **Security Hardened** - Non-root user, minimal attack surface, Docker Scout verified
- **Comprehensive Examples**:
  - Basic Kubernetes deployment
  - Persistent Volume Claim integration
  - Docker Compose for development and production
  - AI/ML model storage examples (Ollama, PyTorch, JupyterHub)
- **Management Scripts** - Automated deployment and maintenance utilities
- **Complete Documentation** - Comprehensive README with troubleshooting guides

### Features
- **Container Security**: Non-root user execution, minimal Alpine base image
- **Network Security**: Configurable client access via CIDR blocks
- **High Performance**: NFSv3/NFSv4 support with optimized configuration
- **Enterprise Ready**: Health checks, graceful shutdown, comprehensive logging
- **Modular Design**: One NFS server per model/dataset for easy scaling
- **Configuration**: Environment-driven configuration for maximum flexibility

### Container Specifications
- **Base Image**: Alpine Linux 3.22.1
- **Size**: < 50MB compressed
- **Ports**: 2049 (NFS), 111 (RPC), 20048 (mountd)
- **User**: nfsuser:1001 (non-root)
- **Health Checks**: Startup, liveness, and readiness probes
- **Attestation**: Full SBOM and provenance with Docker Buildx

### Documentation
- **README.md**: Comprehensive project documentation with examples
- **LICENSE**: MIT License
- **REPOSITORY_STRUCTURE.md**: Complete repository organization guide
- **examples/**: Production-ready deployment manifests
- **scripts/**: Management and automation utilities

### Use Cases
- **AI/ML Model Storage**: Shared storage for large language models (LLaMA, Ollama)
- **Training Workloads**: Distributed dataset access for ML training jobs
- **Microservices**: Shared configuration and asset storage
- **Development**: Team development environments with shared resources
- **Enterprise**: Production-grade shared storage for Kubernetes clusters

### Security
- **Docker Scout Verified**: No high/critical vulnerabilities
- **Minimal Attack Surface**: Only required packages installed
- **Configurable Access**: Client IP restrictions via environment variables
- **Best Practices**: Security contexts, resource limits, network policies

[1.0.1]: https://github.com/boyroywax/nfs-server/releases/tag/v1.0.1
[1.0.0]: https://github.com/boyroywax/nfs-server/releases/tag/v1.0.0
