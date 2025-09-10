# 🚀 Alpine NFS Server v1.0.0 - Production Release

We're excited to announce the first production release of Alpine NFS Server! This lightweight, secure NFS server is purpose-built for Kubernetes environments with special optimization for AI/ML workloads.

## 🌟 What's New

### Production-Ready Container
- **Alpine Linux 3.22.1** base image (< 50MB compressed)
- **Docker Hub**: `boyroywax/nfs-server:1.0.0` with full attestation and SBOM
- **Security hardened** with non-root user execution and minimal attack surface
- **Docker Scout verified** with no high/critical vulnerabilities

### Kubernetes Native
- Complete deployment manifests with health checks
- Startup, liveness, and readiness probes
- Resource limits and security contexts
- Service and PVC integration examples

### AI/ML Optimized
- Specialized examples for model storage and training
- Ollama + LLaMA 3.2 1B deployment example
- PyTorch distributed training with shared datasets
- JupyterHub with shared notebook storage

## 📦 Quick Start

### Docker
```bash
docker run -d --name nfs-server --privileged \
  -e SHARE_NAME=mydata \
  -e CLIENT_CIDR=10.0.0.0/8 \
  -p 2049:2049 -p 20048:20048 -p 111:111 \
  -v /path/to/data:/nfsshare/data \
  boyroywax/nfs-server:1.0.0
```

### Kubernetes
```bash
kubectl apply -f https://raw.githubusercontent.com/boyroywax/nfs-server/v1.0.0/examples/deployment.yaml
```

### Docker Compose
```bash
curl -O https://raw.githubusercontent.com/boyroywax/nfs-server/v1.0.0/examples/docker-compose.yaml
docker-compose up -d
```

## 🛡️ Security Features

- **Non-root execution** (nfsuser:1001)
- **Minimal Alpine base** with only required packages
- **Configurable client access** via CIDR blocks
- **Docker Scout verified** security scanning
- **Regular security updates** via automated builds

## 🎯 Use Cases

### AI/ML Infrastructure
- **Model Storage**: Share large language models across inference pods
- **Training Data**: Distributed dataset access for ML training jobs
- **Team Collaboration**: Shared notebooks and experiment results

### Enterprise Environments
- **Microservices**: Shared configuration and asset storage
- **Development**: Team development environments
- **CI/CD**: Artifact storage and pipeline sharing

### Cloud-Native Applications
- **Kubernetes Ready**: Purpose-built for container orchestration
- **Scalable**: Multiple NFS servers for different use cases
- **Configurable**: Environment-driven configuration

## 📚 Complete Examples

The release includes comprehensive examples:

- **Basic Deployment** ([`examples/deployment.yaml`](examples/deployment.yaml))
- **Persistent Storage** ([`examples/deployment-with-pvc.yaml`](examples/deployment-with-pvc.yaml))
- **Docker Compose** ([`examples/docker-compose.yaml`](examples/docker-compose.yaml))
- **Development** ([`examples/docker-compose.dev.yaml`](examples/docker-compose.dev.yaml))
- **AI/ML Models** ([`examples/ai-model-storage/`](examples/ai-model-storage/))

## 🔧 Configuration

| Environment Variable | Purpose | Default |
|---------------------|---------|---------|
| `SHARE_NAME` | Descriptive name for logging | `default-share` |
| `EXPORT_PATH` | Container path to export | `/nfsshare/data` |
| `CLIENT_CIDR` | Allowed client networks | RFC1918 networks |
| `NFS_OPTIONS` | NFS export options | Secure defaults |
| `TZ` | Timezone for logging | `UTC` |

## 📈 Container Specifications

- **Base Image**: Alpine Linux 3.22.1
- **Size**: < 50MB compressed
- **Ports**: 2049 (NFS), 111 (RPC), 20048 (mountd)
- **User**: nfsuser:1001 (non-root)
- **Health**: Comprehensive startup, liveness, readiness probes
- **Attestation**: Full SBOM and provenance with Docker Buildx

## 🛠️ Management Tools

Included management scripts for easy deployment:

- **`scripts/deploy-llama32-1b.sh`** - Model-specific deployment
- **`scripts/manage-model-nfs.sh`** - Generic NFS management
- **`build-with-attestation.sh`** - Secure container building

## 🚀 Getting Started

1. **Quick Deploy**: 
   ```bash
   kubectl apply -f https://raw.githubusercontent.com/boyroywax/nfs-server/v1.0.0/examples/deployment.yaml
   ```

2. **Development**: 
   ```bash
   git clone https://github.com/boyroywax/nfs-server.git
   cd nfs-server
   docker-compose -f examples/docker-compose.dev.yaml up -d
   ```

3. **AI/ML Models**: 
   ```bash
   kubectl apply -f https://raw.githubusercontent.com/boyroywax/nfs-server/v1.0.0/examples/ai-model-storage/ollama-llama32-1b.yaml
   ```

## 📋 Full Changelog

See [CHANGELOG.md](CHANGELOG.md) for complete details.

## 🤝 Contributing

We welcome contributions! Please see our [README.md](README.md) for development setup and contribution guidelines.

---

**Docker Hub**: https://hub.docker.com/r/boyroywax/nfs-server  
**Documentation**: https://github.com/boyroywax/nfs-server  
**Issues**: https://github.com/boyroywax/nfs-server/issues
