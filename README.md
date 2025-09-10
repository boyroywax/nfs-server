# Alpine NFS Server for Kubernetes

[![Docker Hub](https://img.shields.io/docker/v/boyroywax/nfs-server?label=Docker%20Hub)](https://hub.docker.com/r/boyroywax/nfs-server)
[![Docker Scout](https://img.shields.io/badge/Docker%20Scout-Verified-green)](https://hub.docker.com/r/boyroywax/nfs-server)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A lightweight, secure NFS server built on Alpine Linux, designed for Kubernetes environments with modular model storage architecture. Perfect for AI/ML workloads, microservices shared storage, and cloud-native applications.

## 🚀 Features

- **🏔️ Alpine Linux 3.22.1** - Minimal, secure base image (< 50MB)
- **🔒 Security Hardened** - Non-root user, minimal attack surface, Docker Scout verified
- **⚡ High Performance** - NFSv3/NFSv4 support with optimized configuration
- **🐳 Kubernetes Ready** - Purpose-built for containerized deployments
- **📦 Modular Design** - One NFS server per model/dataset for easy scaling
- **🛡️ Enterprise Ready** - Health checks, graceful shutdown, comprehensive logging
- **🔧 Configurable** - Environment-driven configuration for maximum flexibility

## 📋 Table of Contents

- [Quick Start](#quick-start)
- [Kubernetes Deployment](#kubernetes-deployment)
- [Configuration](#configuration)
- [Use Cases](#use-cases)
- [Security](#security)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## ⚡ Quick Start

### Docker Run

```bash
# Basic NFS server
docker run -d 
  --name nfs-server 
  --privileged 
  -e SHARE_NAME=mydata 
  -e CLIENT_CIDR=10.0.0.0/8 
  -p 2049:2049 
  -p 20048:20048 
  -p 111:111 
  -v /path/to/data:/nfsshare/data 
  boyroywax/nfs-server:1.0.0
```

### Docker Compose

```yaml
version: '3.8'
services:
  nfs-server:
    image: boyroywax/nfs-server:1.0.0
    privileged: true
    environment:
      - SHARE_NAME=shared-storage
      - CLIENT_CIDR=172.20.0.0/16,10.0.0.0/8
    ports:
      - "2049:2049"
      - "20048:20048"
      - "111:111"
    volumes:
      - ./data:/nfsshare/data
    restart: unless-stopped
```

## ☸️ Kubernetes Deployment

### Prerequisites

- Kubernetes cluster with privileged pod support
- kubectl configured and connected to your cluster

### Quick Deploy

```bash
# Deploy to default namespace
kubectl apply -f https://raw.githubusercontent.com/boyroywax/nfs-server/main/examples/deployment.yaml

# Deploy to specific namespace
kubectl apply -f https://raw.githubusercontent.com/boyroywax/nfs-server/main/examples/deployment.yaml -n your-namespace
```

### Custom Deployment

1. **Clone the repository:**
   ```bash
   git clone https://github.com/boyroywax/nfs-server.git
   cd nfs-server
   ```

2. **Customize the deployment:**
   ```bash
   # Edit the deployment configuration
   cp examples/deployment.yaml my-nfs-deployment.yaml
   # Modify as needed...
   ```

3. **Deploy:**
   ```bash
   kubectl apply -f my-nfs-deployment.yaml
   ```

### Using with Persistent Volumes

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: nfs-server.default.svc.cluster.local
    path: "/"
  mountOptions:
    - nfsvers=4.1
    - proto=tcp
    - hard
    - intr
```

## ⚙️ Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SHARE_NAME` | `default-share` | NFS share identifier for logging and management |
| `EXPORT_PATH` | `/nfsshare/data` | Path to export via NFS |
| `CLIENT_CIDR` | `10.0.0.0/8,172.16.0.0/12,192.168.0.0/16` | Comma-separated list of allowed client networks |
| `NFS_OPTIONS` | `rw,sync,no_subtree_check,no_root_squash,insecure` | NFS export options |
| `TZ` | `UTC` | Timezone for logging |

### NFS Export Options

- `rw` - Read-write access
- `sync` - Synchronous writes (safer but slower)
- `no_subtree_check` - Disable subtree checking for better performance
- `no_root_squash` - Allow root access from clients
- `insecure` - Allow connections from ports > 1024

### Security Considerations

For production environments, consider:
- Using `root_squash` instead of `no_root_squash`
- Restricting `CLIENT_CIDR` to specific networks
- Using NFSv4 with Kerberos authentication
- Implementing network policies in Kubernetes

## 🎯 Use Cases

### AI/ML Model Storage
Perfect for serving large language models (LLaMA, Ollama, etc.) across multiple inference pods:

```yaml
# Example: Shared model storage for Ollama
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ollama-llama32-1b
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: ollama
        image: ollama/ollama:latest
        volumeMounts:
        - name: models
          mountPath: /models
      volumes:
      - name: models
        nfs:
          server: nfs-server.default.svc.cluster.local
          path: "/"
```

### Microservices Shared Storage
Enable multiple services to share configuration, assets, or temporary files:

```yaml
# Shared uploads directory
volumes:
- name: shared-uploads
  nfs:
    server: nfs-server.uploads.svc.cluster.local
    path: "/"
```

### Development Environment
Quick shared storage for development teams:

```bash
# Local development with docker-compose
docker-compose -f examples/docker-compose.dev.yaml up -d
```

## 🔒 Security

### Container Security
- **Non-root default user** (`nfsuser:1001`)
- **Minimal Alpine base** with only required packages
- **Regular security updates** via automated builds
- **Docker Scout verified** with no high/critical vulnerabilities

### Network Security
- **Configurable client access** via CIDR blocks
- **Standard NFS ports** (2049, 111, 20048)
- **Optional encryption** (NFSv4 with Kerberos)

### Kubernetes Security
- **SecurityContext** configured for least privilege
- **Resource limits** to prevent resource exhaustion
- **Health checks** for automatic recovery

## 📚 Examples

The `examples/` directory contains various deployment scenarios:

- [`deployment.yaml`](examples/deployment.yaml) - Basic Kubernetes deployment
- [`deployment-with-pvc.yaml`](examples/deployment-with-pvc.yaml) - With persistent volume claim
- [`docker-compose.yaml`](examples/docker-compose.yaml) - Docker Compose setup
- [`docker-compose.dev.yaml`](examples/docker-compose.dev.yaml) - Development environment
- [`ai-model-storage/`](examples/ai-model-storage/) - AI/ML model serving examples

## 🔧 Troubleshooting

### Common Issues

**Pod not starting:**
```bash
# Check if the namespace allows privileged containers
kubectl describe pod <pod-name>

# Check events
kubectl get events --sort-by='.lastTimestamp'
```

**Mount failures:**
```bash
# Test NFS connectivity from a debug pod
kubectl run -it --rm debug --image=busybox --restart=Never -- sh
# Inside the pod:
apk add nfs-utils
showmount -e <nfs-server-ip>
```

**Permission denied:**
```bash
# Check export configuration
kubectl exec <nfs-pod> -- cat /etc/exports
kubectl exec <nfs-pod> -- showmount -e localhost
```

### Performance Tuning

For high-throughput workloads:
```yaml
env:
- name: NFS_OPTIONS
  value: "rw,async,no_subtree_check,no_root_squash,insecure"
```

For safety-critical workloads:
```yaml
env:
- name: NFS_OPTIONS
  value: "rw,sync,subtree_check,root_squash,secure"
```

## 📈 Monitoring

### Health Checks
The container includes built-in health checks:
- **Startup probe** - Ensures NFS service starts correctly
- **Liveness probe** - Monitors ongoing NFS service health
- **Readiness probe** - Indicates when ready to serve traffic

### Logs
```bash
# View NFS server logs
kubectl logs -f <nfs-pod-name>

# View export status
kubectl exec <nfs-pod> -- showmount -e localhost
```

### Metrics
Consider integrating with:
- **Prometheus** - For metrics collection
- **Grafana** - For dashboards
- **AlertManager** - For alerting

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/boyroywax/nfs-server.git
   cd nfs-server
   ```

2. **Build locally:**
   ```bash
   docker build -t nfs-server:dev .
   ```

3. **Test:**
   ```bash
   docker-compose -f examples/docker-compose.dev.yaml up -d
   ```

### Building with Attestation

```bash
# Create buildx builder
docker buildx create --name attestation-builder --driver docker-container --use

# Build with attestation and SBOM
docker buildx build 
  --builder attestation-builder 
  --build-arg BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" 
  --build-arg VCS_REF="$(git rev-parse HEAD)" 
  --build-arg VERSION="1.0.0" 
  --platform linux/amd64 
  --attest type=provenance,mode=max 
  --attest type=sbom 
  -t boyroywax/nfs-server:dev 
  --push 
  .
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Alpine Linux** team for the secure, minimal base image
- **Kubernetes** community for orchestration excellence
- **Docker** for containerization standards
- **Contributors** who help improve this project

---

Built with ❤️ for the cloud-native community.

For questions, issues, or contributions, please visit our [GitHub repository](https://github.com/boyroywax/nfs-server).
