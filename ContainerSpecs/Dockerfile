# Multi-stage Dockerfile for SYNTRA Foundation
# Supports ARM64 and AMD64 architectures
# Based on Cross-Platform Containerization & WebAssembly Blueprint

ARG SWIFT_VERSION=6.2
ARG BASE_IMAGE=swift:${SWIFT_VERSION}-noble

# Build stage
FROM --platform=$BUILDPLATFORM ${BASE_IMAGE} as builder

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    pkg-config \
    libssl-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Install WebAssembly toolchain
RUN curl https://get.wasmer.io -sSfL | sh
ENV PATH="/root/.wasmer/bin:$PATH"

# Set up work directory
WORKDIR /app

# Copy package files first for dependency caching
COPY Package.swift Package.resolved ./
COPY Sources ./Sources
COPY swift ./swift

# Build SYNTRA with static linking for minimal attack surface
RUN swift build -c release \
    --static-swift-stdlib \
    --product SyntraSwift

# WebAssembly compilation stage (when SwiftWasm SDK available)
FROM builder as wasm-builder
RUN echo "WebAssembly compilation stage - requires SwiftWasm SDK"
# TODO: Add SwiftWasm compilation when SDK available
# RUN swift build --swift-sdk swift-6.2-wasm --product SyntraCoreWasm

# Runtime stage - minimal image
FROM ubuntu:24.04 as runtime

# Install minimal runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user for security
RUN useradd --create-home --shell /bin/bash syntra

# Copy built binaries
COPY --from=builder /app/.build/release/SyntraSwift /usr/local/bin/syntra
COPY --chown=syntra:syntra Sources /opt/syntra/Sources
COPY --chown=syntra:syntra config.json /opt/syntra/

# Set up plugin directory for WebAssembly modules
RUN mkdir -p /opt/syntra/plugins && chown syntra:syntra /opt/syntra/plugins

# Switch to non-root user
USER syntra
WORKDIR /opt/syntra

# Health check endpoint
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD /usr/local/bin/syntra --health-check || exit 1

# Expose default port (configurable via environment)
EXPOSE 8080

# Default command
CMD ["/usr/local/bin/syntra"]

# Metadata labels for SBOM and supply chain security
LABEL org.opencontainers.image.title="SYNTRA Foundation"
LABEL org.opencontainers.image.description="Cross-platform AI consciousness runtime with WebAssembly plugin support"
LABEL org.opencontainers.image.vendor="SyntraFoundation"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.source="https://github.com/infektyd/SyntraFoundation" 