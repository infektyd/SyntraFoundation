#!/bin/bash
# Universal Container Build Script for SYNTRA Foundation
# Supports both Apple Containerization (macOS 26) and Docker
# Based on Cross-Platform Containerization & WebAssembly Blueprint

set -euo pipefail

# Configuration
PROJECT_NAME="syntra"
REGISTRY="ghcr.io/infektyd"
TAG="${1:-$(git rev-parse --short HEAD)}"
PLATFORM="${2:-local}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect available container runtime
detect_runtime() {
    if command -v container &> /dev/null && [[ "$OSTYPE" == "darwin"* ]]; then
        echo "apple"
    elif command -v docker &> /dev/null; then
        echo "docker"
    elif command -v podman &> /dev/null; then
        echo "podman"
    else
        echo "none"
    fi
}

# Build with Apple Containerization (macOS 26)
build_with_apple() {
    log_info "Building with Apple Containerization framework"
    
    # Start container system if not running
    container system start || true
    
    # Build multi-arch image
    container build \
        --tag "${PROJECT_NAME}:${TAG}" \
        --tag "${PROJECT_NAME}:latest" \
        --memory 4GB \
        --cpus 4 \
        --file ContainerSpecs/Dockerfile \
        .
    
    log_info "Apple container build completed: ${PROJECT_NAME}:${TAG}"
}

# Build with Docker
build_with_docker() {
    log_info "Building with Docker"
    
    if [[ "$PLATFORM" == "multiarch" ]]; then
        # Multi-architecture build
        docker buildx create --name syntra-builder --use || true
        docker buildx build \
            --platform linux/arm64,linux/amd64 \
            --tag "${REGISTRY}/${PROJECT_NAME}:${TAG}" \
            --tag "${REGISTRY}/${PROJECT_NAME}:latest" \
            --file ContainerSpecs/Dockerfile \
            --push \
            .
    else
        # Local build
        docker build \
            --tag "${PROJECT_NAME}:${TAG}" \
            --tag "${PROJECT_NAME}:latest" \
            --file ContainerSpecs/Dockerfile \
            .
    fi
    
    log_info "Docker build completed: ${PROJECT_NAME}:${TAG}"
}

# Build with Podman
build_with_podman() {
    log_info "Building with Podman"
    
    podman build \
        --tag "${PROJECT_NAME}:${TAG}" \
        --tag "${PROJECT_NAME}:latest" \
        --file ContainerSpecs/Dockerfile \
        .
    
    log_info "Podman build completed: ${PROJECT_NAME}:${TAG}"
}

# Main build logic
main() {
    log_info "SYNTRA Foundation Container Build"
    log_info "Platform: $PLATFORM, Tag: $TAG"
    
    # Ensure we're in the project root
    if [[ ! -f "Package.swift" ]]; then
        log_error "Please run this script from the SYNTRA Foundation root directory"
        exit 1
    fi
    
    # Detect and use appropriate runtime
    RUNTIME=$(detect_runtime)
    
    case "$RUNTIME" in
        "apple")
            build_with_apple
            ;;
        "docker")
            build_with_docker
            ;;
        "podman")
            build_with_podman
            ;;
        "none")
            log_error "No container runtime found. Please install Docker, Podman, or Apple Container CLI"
            exit 1
            ;;
    esac
    
    log_info "Container build complete!"
    log_info "To run: ${RUNTIME} run -p 8080:8080 ${PROJECT_NAME}:${TAG}"
}

# Run main function
main "$@" 