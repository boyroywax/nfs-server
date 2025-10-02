# Repository Structure and Organization

This document describes the complete structure of the Alpine NFS Server repository, designed for GitHub publication.

## 📁 Repository Structure

```
├── README.md                           # Main project documentation
├── LICENSE                             # MIT license
├── Dockerfile                          # Alpine NFS server container
├── .dockerignore                       # Docker build exclusions
├── build-with-attestation.sh          # Buildx with attestation script
├── examples/                           # Deployment examples
│   ├── deployment.yaml                 # Basic Kubernetes deployment
│   ├── deployment-with-pvc.yaml       # Deployment with persistent storage
│   ├── docker-compose.yaml            # Docker Compose setup
│   ├── docker-compose.dev.yaml        # Development environment
│   └── ai-model-storage/              # AI/ML specific examples
│       ├── README.md                   # AI/ML use cases documentation
│       ├── ollama-llama32-1b.yaml    # Ollama LLaMA deployment
│       ├── pytorch-training.yaml      # PyTorch training example
│       └── jupyter-notebooks.yaml     # JupyterHub with shared storage
├── scripts/                           # Management utilities
│   ├── deploy-llama32-1b.sh          # Model-specific deployment script
│   └── manage-model-nfs.sh           # Generic model management
└── docs/                              # Additional documentation (optional)
    ├── CONTRIBUTING.md                # Contribution guidelines
    ├── SECURITY.md                    # Security policies
    └── CHANGELOG.md                   # Version history
```

## 🎯 Key Features

### Production Ready
- **Docker Hub**: `boyroywax/nfs-server:1.0.1` with attestation and SBOM
- **Security**: Docker Scout verified, minimal Alpine base, non-root user
- **Health Checks**: Comprehensive probes for Kubernetes deployment
- **Documentation**: Complete examples and troubleshooting guides

### Comprehensive Examples
- **Basic Deployment**: Simple Kubernetes setup with service
- **Persistent Storage**: PVC integration for data persistence
- **Docker Compose**: Local development and testing
- **AI/ML Workloads**: Specialized examples for model storage and training

### Developer Experience
- **Quick Start**: One-command deployment options
- **Management Scripts**: Automated deployment and maintenance tools
- **Development Environment**: Docker Compose dev setup with debugging
- **Troubleshooting**: Common issues and solutions documented

## 🚀 Getting Started

### For Users
1. **Quick Deploy**: `kubectl apply -f https://raw.githubusercontent.com/pocketminers/nfs-server/main/examples/deployment.yaml`
2. **Docker Compose**: `docker-compose -f examples/docker-compose.yaml up -d`
3. **AI/ML Models**: Use examples in `ai-model-storage/` directory

### For Contributors
1. **Clone**: `git clone https://github.com/pocketminers/nfs-server.git`
2. **Build**: `docker build -t nfs-server:dev .`
3. **Test**: `docker-compose -f examples/docker-compose.dev.yaml up -d`

## 📦 Container Features

- **Base Image**: Alpine Linux 3.22.1 (minimal, secure)
- **Size**: < 50MB compressed
- **Security**: Non-root user, minimal packages, hardened configuration
- **Performance**: Optimized NFS configuration, configurable options
- **Monitoring**: Built-in health checks and logging
- **Attestation**: Full SBOM and provenance with Docker Scout verification

## 🎭 Use Cases

### AI/ML Infrastructure
- **Model Storage**: Shared storage for large language models
- **Training Data**: Distributed dataset access for training jobs
- **Collaboration**: Team-shared notebooks and experiment results

### Enterprise Environments
- **Microservices**: Shared configuration and asset storage
- **Development**: Team development environments with shared resources
- **CI/CD**: Artifact storage and sharing between pipeline stages

### Cloud-Native Applications
- **Kubernetes Native**: Designed specifically for container orchestration
- **Scalable**: Multiple NFS servers for different use cases
- **Configurable**: Environment-driven configuration management

## 🔧 Configuration Options

| Environment Variable | Purpose | Default |
|---------------------|---------|---------|
| `SHARE_NAME` | Descriptive name for logging | `default-share` |
| `EXPORT_PATH` | Container path to export | `/nfsshare/data` |
| `CLIENT_CIDR` | Allowed client networks | RFC1918 networks |
| `NFS_OPTIONS` | NFS export options | Secure defaults |
| `TZ` | Timezone for logging | `UTC` |

## 📈 Deployment Patterns

### Single Model Pattern
- One NFS server per AI model
- Dedicated storage and resource allocation
- Easy scaling and model versioning

### Shared Storage Pattern
- One NFS server for multiple related services
- Cost-effective for smaller deployments
- Simplified management and monitoring

### Development Pattern
- Quick setup for development and testing
- Easy teardown and recreation
- Debug-friendly configuration

## 🛡️ Security Considerations

### Container Security
- Non-root user execution where possible
- Minimal package installation
- Regular security updates via Alpine base
- Docker Scout continuous scanning

### Network Security
- Configurable client IP restrictions
- Standard NFS port configuration
- Optional encryption support (NFSv4 + Kerberos)
- Kubernetes network policy integration

### Access Control
- Configurable NFS export options
- Root squashing options for production
- Client authentication and authorization
- Audit logging capabilities

## 📊 Monitoring and Observability

### Health Checks
- **Startup Probe**: Ensures proper NFS service initialization
- **Readiness Probe**: Indicates when ready to serve clients
- **Liveness Probe**: Monitors ongoing service health

### Logging
- Structured JSON logging with configurable levels
- NFS operation logging for debugging
- Client connection and authentication logs
- Performance metrics and statistics

### Integration
- Prometheus metrics endpoint (optional)
- Grafana dashboard templates
- AlertManager integration examples
- Log aggregation compatibility

## 🤝 Community and Support

### Documentation
- Comprehensive README with examples
- API documentation for advanced configuration
- Troubleshooting guides with common solutions
- Best practices for production deployment

### Contributing
- Clear contribution guidelines
- Issue templates for bugs and features
- Pull request templates and review process
- Code of conduct and community standards

### Support Channels
- GitHub Issues for bugs and feature requests
- GitHub Discussions for questions and ideas
- Documentation wiki for community contributions
- Security reporting process for vulnerabilities

---

This repository structure provides a complete, professional-grade NFS server solution for Kubernetes environments, with particular strength in AI/ML workloads and cloud-native applications.
