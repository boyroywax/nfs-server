# Security Fix Summary - v1.0.1

## Overview
Version 1.0.1 addresses **2 high-severity vulnerabilities** (CVSS 7.5) discovered in the Alpine Linux base image packages.

## Vulnerabilities Fixed

### CVE-2025-9230 (OpenSSL)
- **Severity**: High (CVSS 7.5)
- **Package**: openssl
- **Vulnerable Version**: 3.5.2-r0
- **Fixed Version**: 3.5.4-r0
- **Location**: Layer 3 (Alpine package)
- **Impact**: Security vulnerability in OpenSSL library

### CVE-2025-59375 (Expat)
- **Severity**: High (CVSS 7.5)
- **Package**: expat
- **Vulnerable Version**: 2.7.1-r0
- **Fixed Version**: 2.7.2-r0
- **Location**: Layer 3 (Alpine package)
- **Impact**: Security vulnerability in Expat XML parser

## Resolution

The Dockerfile has been updated to explicitly require the fixed package versions:

```dockerfile
RUN apk update && apk upgrade && \
    apk add --no-cache \
    'openssl>=3.5.4-r0' \
    'expat>=2.7.2-r0' \
    nfs-utils \
    rpcbind \
    bash \
    util-linux \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*
```

## Verification

After building the new image, you can verify the fixed versions:

```bash
# Build the image
docker build -t boyroywax/nfs-server:1.0.1 .

# Verify OpenSSL version
docker run --rm boyroywax/nfs-server:1.0.1 apk info openssl

# Verify Expat version
docker run --rm boyroywax/nfs-server:1.0.1 apk info expat

# Expected output:
# openssl-3.5.4-r0 (or higher)
# expat-2.7.2-r0 (or higher)
```

## Docker Scout Compliance

After these changes, the image should achieve:
- ✅ **0 Critical vulnerabilities**
- ✅ **0 High vulnerabilities** (down from 2)
- ✅ **Compliance Status**: Compliant
- ✅ **Health Score**: A (improved from B)

## Build & Push Instructions

```bash
# Build with attestation
./build-with-attestation.sh 1.0.1

# Or manually with Docker
docker build \
  --build-arg BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
  --build-arg VCS_REF="$(git rev-parse HEAD)" \
  --build-arg VERSION="1.0.1" \
  -t boyroywax/nfs-server:1.0.1 \
  .

# Tag as latest
docker tag boyroywax/nfs-server:1.0.1 boyroywax/nfs-server:latest

# Push to Docker Hub
docker push boyroywax/nfs-server:1.0.1
docker push boyroywax/nfs-server:latest
```

## Upgrade Path

All users should upgrade from v1.0.0 to v1.0.1 immediately. See [RELEASE_NOTES_v1.0.1.md](RELEASE_NOTES_v1.0.1.md) for detailed upgrade instructions.

### Quick Upgrade

**Kubernetes:**
```bash
kubectl set image deployment/nfs-server nfs-server=boyroywax/nfs-server:1.0.1
```

**Docker:**
```bash
docker pull boyroywax/nfs-server:1.0.1
docker stop nfs-server && docker rm nfs-server
docker run -d --name nfs-server --privileged ... boyroywax/nfs-server:1.0.1
```

**Docker Compose:**
```bash
# Update image tag in docker-compose.yaml to 1.0.1
docker-compose down && docker-compose up -d
```

## Timeline

- **Issue Discovered**: October 2, 2025 (via Docker Scout)
- **Fix Applied**: October 2, 2025
- **Release**: v1.0.1 - October 2, 2025

## References

- [CVE-2025-9230](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2025-9230) - OpenSSL vulnerability
- [CVE-2025-59375](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2025-59375) - Expat vulnerability
- [Alpine Linux Security](https://alpinelinux.org/security/) - Alpine security advisories
- [Docker Scout](https://docs.docker.com/scout/) - Container security scanning

---

**Status**: ✅ Fixed in v1.0.1  
**Action Required**: Upgrade to v1.0.1 immediately
