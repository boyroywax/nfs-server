# 🔒 Alpine NFS Server v1.0.1 - Security Update

**Release Date:** October 2, 2025  
**Type:** Patch Release (Security)

## 🚨 Security Update

This is a security patch release that addresses OpenSSL vulnerabilities in the Alpine Linux base image.

## 📦 What's Changed

### Security Fixes
- **Alpine Base Image Update** - Updated from Alpine Linux 3.22.1 to 3.22 (latest) to address OpenSSL security vulnerabilities
- **CVE Resolution** - Resolves multiple CVEs in the openssl package through base image update

### Updated Components
- **Base Image**: `alpine:3.22` (from 3.22.1, now tracks latest 3.22.x)
- **Docker Image**: `boyroywax/nfs-server:1.0.1`
- **Version**: 1.0.1

## 📥 Installation

### Docker Hub

```bash
docker pull boyroywax/nfs-server:1.0.1
```

### Quick Start

```bash
docker run -d \
  --name nfs-server \
  --privileged \
  -e SHARE_NAME=mydata \
  -e CLIENT_CIDR=10.0.0.0/8 \
  -p 2049:2049 \
  -p 20048:20048 \
  -p 111:111 \
  -v /path/to/data:/nfsshare/data \
  boyroywax/nfs-server:1.0.1
```

### Kubernetes Deployment

```bash
kubectl apply -f https://raw.githubusercontent.com/boyroywax/nfs-server/v1.0.1/examples/deployment.yaml
```

### Docker Compose

```bash
curl -O https://raw.githubusercontent.com/boyroywax/nfs-server/v1.0.1/examples/docker-compose.yaml
docker-compose up -d
```

## 🔄 Upgrade Guide

### From v1.0.0 to v1.0.1

This is a drop-in replacement with no configuration changes required.

#### Docker

```bash
# Pull the new version
docker pull boyroywax/nfs-server:1.0.1

# Stop and remove old container
docker stop nfs-server
docker rm nfs-server

# Start with new version (same configuration)
docker run -d \
  --name nfs-server \
  --privileged \
  -e SHARE_NAME=mydata \
  -e CLIENT_CIDR=10.0.0.0/8 \
  -p 2049:2049 \
  -p 20048:20048 \
  -p 111:111 \
  -v /path/to/data:/nfsshare/data \
  boyroywax/nfs-server:1.0.1
```

#### Kubernetes

```bash
# Update the image in your deployment
kubectl set image deployment/nfs-server nfs-server=boyroywax/nfs-server:1.0.1

# Or apply the updated manifest
kubectl apply -f https://raw.githubusercontent.com/boyroywax/nfs-server/v1.0.1/examples/deployment.yaml
```

#### Docker Compose

```bash
# Update image version in docker-compose.yaml
# Then restart services
docker-compose down
docker-compose up -d
```

## 📋 Version Comparison

| Component | v1.0.0 | v1.0.1 |
|-----------|--------|--------|
| Alpine Base | 3.22.1 | 3.22 (latest) |
| OpenSSL | Vulnerable | Patched |
| Configuration | Same | Same |
| Features | Same | Same |

## 🛡️ Security Benefits

- **Patched OpenSSL vulnerabilities** in Alpine Linux base image
- **Same security posture** as v1.0.0 with updated dependencies
- **No breaking changes** to existing deployments
- **Minimal image size** maintained (< 50MB compressed)

## 📚 Documentation

- **README**: [https://github.com/boyroywax/nfs-server/blob/v1.0.1/README.md](https://github.com/boyroywax/nfs-server/blob/v1.0.1/README.md)
- **CHANGELOG**: [https://github.com/boyroywax/nfs-server/blob/v1.0.1/CHANGELOG.md](https://github.com/boyroywax/nfs-server/blob/v1.0.1/CHANGELOG.md)
- **Examples**: [https://github.com/boyroywax/nfs-server/tree/v1.0.1/examples](https://github.com/boyroywax/nfs-server/tree/v1.0.1/examples)

## 🔗 Links

- **Docker Hub**: [https://hub.docker.com/r/boyroywax/nfs-server](https://hub.docker.com/r/boyroywax/nfs-server)
- **GitHub Repository**: [https://github.com/boyroywax/nfs-server](https://github.com/boyroywax/nfs-server)
- **Issue Tracker**: [https://github.com/boyroywax/nfs-server/issues](https://github.com/boyroywax/nfs-server/issues)

## 📝 Notes

- This is a security-focused patch release
- No new features or functionality changes
- Backwards compatible with v1.0.0
- Recommended for all users to upgrade for security purposes

## ⚠️ Important

**Action Required:** All users running v1.0.0 should upgrade to v1.0.1 to address OpenSSL security vulnerabilities.

---

**Full Changelog**: [v1.0.0...v1.0.1](https://github.com/boyroywax/nfs-server/compare/v1.0.0...v1.0.1)
