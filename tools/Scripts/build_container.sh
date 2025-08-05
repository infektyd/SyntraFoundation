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
BLUE='\033[0;34m'
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

log_build() {
    echo -e "${BLUE}[BUILD]${NC} $1"
}

# Validate inputs
validate_inputs() {
    if [[ -z "$TAG" ]]; then
        log_error "Tag cannot be empty"
        exit 1
    fi
    
    if [[ ! "$PLATFORM" =~ ^(local|multiarch|apple|docker|podman)$ ]]; then
        log_error "Invalid platform: $PLATFORM. Must be: local, multiarch, apple, docker, or podman"
        exit 1
    fi
    
    log_info "SYNTRA Foundation Container Build"
    log_info "Platform: $PLATFORM, Tag: $TAG"
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

# Check prerequisites
check_prerequisites() {
    log_info "Checking container build prerequisites"
    
    # Check if we're in the right directory
    if [[ ! -f "ContainerSpecs/Dockerfile" ]]; then
        log_error "ContainerSpecs/Dockerfile not found. Run from project root."
        exit 1
    fi
    
    # Check git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_warn "Not in a git repository. Using timestamp as tag."
        TAG="$(date +%s)"
    fi
    
    # Check available runtime
    local runtime=$(detect_runtime)
    if [[ "$runtime" == "none" ]]; then
        log_error "No container runtime found. Please install Docker, Podman, or Apple Container CLI"
        log_info "Installation options:"
        log_info "  Docker: brew install docker"
        log_info "  Podman: brew install podman"
        log_info "  Apple Container: Available in macOS 26+"
        exit 1
    fi
    
    log_info "Detected runtime: $runtime"
}

# Build with Apple Containerization (macOS 26)
build_with_apple() {
    log_build "Building with Apple Containerization framework"
    
    # Start container system if not running
    if ! container system info &> /dev/null; then
        log_info "Starting Apple Container system"
        container system start || {
            log_error "Failed to start Apple Container system"
            exit 1
        }
    fi
    
    # Build multi-arch image with proper resource allocation
    log_build "Building container image: ${PROJECT_NAME}:${TAG}"
    container build \
        --tag "${PROJECT_NAME}:${TAG}" \
        --tag "${PROJECT_NAME}:latest" \
        --memory 4GB \
        --cpus 4 \
        --file ContainerSpecs/Dockerfile \
        --progress plain \
        . || {
        log_error "Apple container build failed"
        exit 1
    }
    
    log_info "Apple container build completed: ${PROJECT_NAME}:${TAG}"
    
    # Show build info
    container images | grep "${PROJECT_NAME}" || true
}

# Build with Docker
build_with_docker() {
    log_build "Building with Docker"
    
    if [[ "$PLATFORM" == "multiarch" ]]; then
        # Multi-architecture build
        log_build "Building multi-architecture image"
        
        # Create and use buildx builder
        docker buildx create --name syntra-builder --use 2>/dev/null || true
        
        # Build and push multi-arch image
        docker buildx build \
            --platform linux/arm64,linux/amd64 \
            --tag "${REGISTRY}/${PROJECT_NAME}:${TAG}" \
            --tag "${REGISTRY}/${PROJECT_NAME}:latest" \
            --file ContainerSpecs/Dockerfile \
            --push \
            --progress plain \
            . || {
            log_error "Docker multi-arch build failed"
            exit 1
        }
        
        log_info "Docker multi-arch build completed: ${REGISTRY}/${PROJECT_NAME}:${TAG}"
    else
        # Local build
        log_build "Building local Docker image"
        docker build \
            --tag "${PROJECT_NAME}:${TAG}" \
            --tag "${PROJECT_NAME}:latest" \
            --file ContainerSpecs/Dockerfile \
            --progress plain \
            . || {
            log_error "Docker build failed"
            exit 1
        }
        
        log_info "Docker build completed: ${PROJECT_NAME}:${TAG}"
        
        # Show build info
        docker images | grep "${PROJECT_NAME}" || true
    fi
}

# Build with Podman
build_with_podman() {
    log_build "Building with Podman"
    
    podman build \
        --tag "${PROJECT_NAME}:${TAG}" \
        --tag "${PROJECT_NAME}:latest" \
        --file ContainerSpecs/Dockerfile \
        . || {
        log_error "Podman build failed"
        exit 1
    }
    
    log_info "Podman build completed: ${PROJECT_NAME}:${TAG}"
    
    # Show build info
    podman images | grep "${PROJECT_NAME}" || true
}

# Generate SBOM (Software Bill of Materials)
generate_sbom() {
    log_info "Generating Software Bill of Materials"
    
    if command -v syft &> /dev/null; then
        local sbom_file="syntra-sbom-${TAG}.json"
        syft "${PROJECT_NAME}:${TAG}" -o json > "$sbom_file" || {
            log_warn "SBOM generation failed"
            return 1
        }
        log_info "SBOM generated: $sbom_file"
    else
        log_warn "syft not found. Install for SBOM generation: brew install syft"
    fi
}

# Security scan
security_scan() {
    log_info "Running security scan"
    
    if command -v trivy &> /dev/null; then
        local scan_file="syntra-scan-${TAG}.json"
        trivy image --format json --output "$scan_file" "${PROJECT_NAME}:${TAG}" || {
            log_warn "Security scan failed"
            return 1
        }
        log_info "Security scan completed: $scan_file"
    else
        log_warn "trivy not found. Install for security scanning: brew install trivy"
    fi
}

# Main build function
main() {
    validate_inputs
    check_prerequisites
    
    local runtime=$(detect_runtime)
    
    case "$runtime" in
        "apple")
            build_with_apple
            ;;
        "docker")
            build_with_docker
            ;;
        "podman")
            build_with_podman
            ;;
        *)
            log_error "Unsupported runtime: $runtime"
            exit 1
            ;;
    esac
    
    # Post-build tasks
    generate_sbom
    security_scan
    
    log_info "Container build process completed successfully"
    log_info "Image: ${PROJECT_NAME}:${TAG}"
    log_info "Runtime: $runtime"
    log_info "Platform: $PLATFORM"
}

# Run main function
main "$@" 