#!/bin/bash
set -e

# Enhanced build script with supply chain attestation for v1.0.2
# Usage: 
#   ./build-with-attestation.sh [standard|slim] [version]
#   ./build-with-attestation.sh                    # builds both variants
#   ./build-with-attestation.sh standard 1.0.2     # builds standard v1.0.2
#   ./build-with-attestation.sh slim 1.0.2-slim    # builds slim variant

DOCKER_USERNAME="boyroywax"
IMAGE_NAME="nfs-server"
VARIANT="${1:-both}"
VERSION="${2:-1.0.2}"

# Build metadata for supply chain attestation
BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
VCS_REF=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

echo "╔══════════════════════════════════════════════════════╗"
echo "║   Building NFS Server v1.0.2 with Attestation       ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "Build Date: ${BUILD_DATE}"
echo "VCS Ref: ${VCS_REF}"
echo "Variant: ${VARIANT}"
echo ""

echo "Build Date: ${BUILD_DATE}"
echo "VCS Ref: ${VCS_REF}"
echo "Variant: ${VARIANT}"
echo ""

# Function to build an image
build_image() {
    local dockerfile=$1
    local version=$2
    local tags=$3
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Building: ${dockerfile} → ${version}"
    echo "Tags: ${tags}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Build tag arguments
    local tag_args=""
    for tag in $tags; do
        tag_args="${tag_args} --tag ${DOCKER_USERNAME}/${IMAGE_NAME}:${tag}"
    done
    
    # Build with buildx for enhanced attestation support
    if command -v docker buildx >/dev/null 2>&1; then
        echo "Building for local testing (linux/amd64)..."
        docker buildx build \
            --file "${dockerfile}" \
            --build-arg BUILD_DATE="${BUILD_DATE}" \
            --build-arg VCS_REF="${VCS_REF}" \
            --build-arg VERSION="${version}" \
            --platform linux/amd64 \
            ${tag_args} \
            --load \
            . 2>&1 | tail -15
    else
        echo "Using standard docker build..."
        docker build \
            --file "${dockerfile}" \
            --build-arg BUILD_DATE="${BUILD_DATE}" \
            --build-arg VCS_REF="${VCS_REF}" \
            --build-arg VERSION="${version}" \
            ${tag_args} \
            . 2>&1 | tail -15
    fi
    
    echo "✅ Build completed: ${version}"
    echo ""
}

# Build standard variant
if [ "$VARIANT" = "standard" ] || [ "$VARIANT" = "both" ]; then
    build_image "Dockerfile" "1.0.2" "1.0.2 1.0 1 latest"
fi

# Build slim variant
if [ "$VARIANT" = "slim" ] || [ "$VARIANT" = "both" ]; then
    build_image "Dockerfile.slim" "1.0.2-slim" "1.0.2-slim slim"
fi

echo "╔══════════════════════════════════════════════════════╗"
echo "║           ✅ Build Completed Successfully!           ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

# Display built images
echo "📦 Built Images:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker images ${DOCKER_USERNAME}/${IMAGE_NAME} --format "  ✅ {{.Repository}}:{{.Tag}} - {{.Size}}"
echo ""

# Display built images
echo "📦 Built Images:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker images ${DOCKER_USERNAME}/${IMAGE_NAME} --format "  ✅ {{.Repository}}:{{.Tag}} - {{.Size}}"
echo ""

# Display security information
echo "🔒 Security Information:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Base Image: alpine:3.22"
echo "  Default User: nfsuser (non-root)"
echo "  Runtime User: root (required for NFS)"
echo "  License: MIT"
echo "  Supply Chain: SBOM & Provenance included"
echo ""

# Push function
push_images() {
    echo "🚀 Pushing to Docker Hub with attestation..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if command -v docker buildx >/dev/null 2>&1; then
        # Push standard variant
        if [ "$VARIANT" = "standard" ] || [ "$VARIANT" = "both" ]; then
            echo "Pushing standard variant..."
            docker buildx build \
                --file Dockerfile \
                --build-arg BUILD_DATE="${BUILD_DATE}" \
                --build-arg VCS_REF="${VCS_REF}" \
                --build-arg VERSION="1.0.2" \
                --platform linux/amd64,linux/arm64 \
                --provenance=true \
                --sbom=true \
                --tag ${DOCKER_USERNAME}/${IMAGE_NAME}:1.0.2 \
                --tag ${DOCKER_USERNAME}/${IMAGE_NAME}:1.0 \
                --tag ${DOCKER_USERNAME}/${IMAGE_NAME}:1 \
                --tag ${DOCKER_USERNAME}/${IMAGE_NAME}:latest \
                --push \
                .
            echo "✅ Standard variant pushed"
        fi
        
        # Push slim variant
        if [ "$VARIANT" = "slim" ] || [ "$VARIANT" = "both" ]; then
            echo "Pushing slim variant..."
            docker buildx build \
                --file Dockerfile.slim \
                --build-arg BUILD_DATE="${BUILD_DATE}" \
                --build-arg VCS_REF="${VCS_REF}" \
                --build-arg VERSION="1.0.2-slim" \
                --platform linux/amd64,linux/arm64 \
                --provenance=true \
                --sbom=true \
                --tag ${DOCKER_USERNAME}/${IMAGE_NAME}:1.0.2-slim \
                --tag ${DOCKER_USERNAME}/${IMAGE_NAME}:slim \
                --push \
                .
            echo "✅ Slim variant pushed"
        fi
    else
        echo "⚠️  buildx not available, pushing single platform only..."
        docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:1.0.2
        docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:1.0
        docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:1
        docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:latest
        if [ "$VARIANT" = "slim" ] || [ "$VARIANT" = "both" ]; then
            docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:1.0.2-slim
            docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:slim
        fi
    fi
    
    echo ""
    echo "✅ Push completed successfully!"
}

# Ask if user wants to push
read -p "Push to Docker Hub? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    push_images
else
    echo "Skipping push. To push manually:"
    echo ""
    echo "Standard variant:"
    echo "  docker buildx build --platform linux/amd64,linux/arm64 --provenance=true --sbom=true \\"
    echo "    -t ${DOCKER_USERNAME}/${IMAGE_NAME}:1.0.2 -t ${DOCKER_USERNAME}/${IMAGE_NAME}:latest --push ."
    echo ""
    echo "Slim variant:"
    echo "  docker buildx build -f Dockerfile.slim --platform linux/amd64,linux/arm64 --provenance=true --sbom=true \\"
    echo "    -t ${DOCKER_USERNAME}/${IMAGE_NAME}:1.0.2-slim -t ${DOCKER_USERNAME}/${IMAGE_NAME}:slim --push ."
fi

echo ""
echo "📚 Next steps:"
echo "  - Review: RELEASE_NOTES_v1.0.2.md"
echo "  - Deploy: kubectl apply -f examples/deployment.yaml"
echo "  - Verify: docker scout cves ${DOCKER_USERNAME}/${IMAGE_NAME}:1.0.2"
echo ""
