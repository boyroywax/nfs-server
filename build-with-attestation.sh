#!/bin/bash
set -e

# Enhanced build script with supply chain attestation
# Usage: ./build-with-attestation.sh [tag]

DOCKER_USERNAME="boyroywax"
IMAGE_NAME="nfs-server"
TAG="${1:-latest}"
FULL_IMAGE="${DOCKER_USERNAME}/${IMAGE_NAME}:${TAG}"

# Build metadata for supply chain attestation
BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
VCS_REF=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
VERSION="1.0.0"

echo "Building Enhanced NFS Server with Supply Chain Attestation..."
echo "Image: ${FULL_IMAGE}"
echo "Build Date: ${BUILD_DATE}"
echo "VCS Ref: ${VCS_REF}"
echo "Version: ${VERSION}"

# Build with buildx for enhanced attestation support
if command -v docker buildx >/dev/null 2>&1; then
    echo "Using buildx for enhanced security attestation..."
    docker buildx build \
        --build-arg BUILD_DATE="${BUILD_DATE}" \
        --build-arg VCS_REF="${VCS_REF}" \
        --build-arg VERSION="${VERSION}" \
        --platform linux/amd64,linux/arm64 \
        --provenance=true \
        --sbom=true \
        --tag "${FULL_IMAGE}" \
        --load \
        .
else
    echo "Building with standard docker (limited attestation)..."
    docker build \
        --build-arg BUILD_DATE="${BUILD_DATE}" \
        --build-arg VCS_REF="${VCS_REF}" \
        --build-arg VERSION="${VERSION}" \
        --tag "${FULL_IMAGE}" \
        .
fi

# Tag as latest if building a specific version
if [ "$TAG" != "latest" ]; then
    docker tag "${FULL_IMAGE}" "${DOCKER_USERNAME}/${IMAGE_NAME}:latest"
fi

echo "Build completed successfully!"
echo "Image: ${FULL_IMAGE}"

# Display security information
echo ""
echo "=== Security Information ==="
echo "Base Image: alpine:3.22.1 (latest stable)"
echo "Default User: nfsuser (non-root)"
echo "Runtime User: root (required for NFS services)"
echo "License: MIT"
echo "Supply Chain: Enhanced metadata included"

# Ask if user wants to push
read -p "Push to Docker Hub? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Pushing to Docker Hub with attestation..."
    if command -v docker buildx >/dev/null 2>&1; then
        docker buildx build \
            --build-arg BUILD_DATE="${BUILD_DATE}" \
            --build-arg VCS_REF="${VCS_REF}" \
            --build-arg VERSION="${VERSION}" \
            --platform linux/amd64,linux/arm64 \
            --provenance=true \
            --sbom=true \
            --tag "${FULL_IMAGE}" \
            --push \
            .
        if [ "$TAG" != "latest" ]; then
            docker buildx build \
                --build-arg BUILD_DATE="${BUILD_DATE}" \
                --build-arg VCS_REF="${VCS_REF}" \
                --build-arg VERSION="${VERSION}" \
                --platform linux/amd64,linux/arm64 \
                --provenance=true \
                --sbom=true \
                --tag "${DOCKER_USERNAME}/${IMAGE_NAME}:latest" \
                --push \
                .
        fi
    else
        docker push "${FULL_IMAGE}"
        if [ "$TAG" != "latest" ]; then
            docker push "${DOCKER_USERNAME}/${IMAGE_NAME}:latest"
        fi
    fi
    echo "Push completed!"
else
    echo "Skipping push. To push manually with attestation:"
    echo "  docker buildx build --platform linux/amd64,linux/arm64 --provenance=true --sbom=true --push -t ${FULL_IMAGE} ."
fi

echo ""
echo "To deploy to Kubernetes:"
echo "  ./manage-model-nfs.sh deploy my-model 10Gi"
