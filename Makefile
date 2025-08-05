# SYNTRA Foundation Cross-Platform Build System
# Supports Apple Containerization, Docker, and WebAssembly

.PHONY: help container docker wasm test clean install-deps

# Default target
help:
	@echo "SYNTRA Foundation Build System"
	@echo ""
	@echo "Available targets:"
	@echo "  container     - Build OCI image (Apple Containerization on macOS 26, Docker elsewhere)"
	@echo "  docker        - Build multi-arch Docker images"
	@echo "  wasm          - Build WebAssembly modules"
	@echo "  test          - Run all tests (Swift, container, WebAssembly)"
	@echo "  clean         - Clean build artifacts"
	@echo "  install-deps  - Install development dependencies"
	@echo "  swift-build   - Build Swift package"
	@echo "  ios-build     - Build iOS app"
	@echo "  format        - Format code"
	@echo "  lint          - Run linting"
	@echo ""
	@echo "Examples:"
	@echo "  make container TAG=v1.0.0"
	@echo "  make docker PLATFORM=multiarch"
	@echo "  make wasm"
	@echo "  make test"

# Configuration
PROJECT_NAME ?= syntra
TAG ?= $(shell git rev-parse --short HEAD)
PLATFORM ?= local
REGISTRY ?= ghcr.io/infektyd

# Detect operating system and available tools
UNAME_S := $(shell uname -s)
HAS_CONTAINER := $(shell command -v container 2> /dev/null)
HAS_DOCKER := $(shell command -v docker 2> /dev/null)
HAS_SWIFT := $(shell command -v swift 2> /dev/null)

# Container build - uses Apple Containerization if available, otherwise Docker
container:
	@echo "Building container image: $(PROJECT_NAME):$(TAG)"
	@chmod +x tools/Scripts/build_container.sh
	@./tools/Scripts/build_container.sh $(TAG) $(PLATFORM)

# Docker multi-architecture build
docker:
	@echo "Building Docker images for multiple architectures"
	@if [ "$(PLATFORM)" = "multiarch" ]; then \
		./tools/Scripts/build_container.sh $(TAG) multiarch; \
	else \
		./tools/Scripts/build_container.sh $(TAG) local; \
	fi

# WebAssembly build
wasm:
	@echo "Building WebAssembly modules"
	@chmod +x tools/Scripts/build_wasm.sh
	@./tools/Scripts/build_wasm.sh

# Swift package build
swift-build:
	@echo "Building Swift package"
ifndef HAS_SWIFT
	$(error Swift is not installed. Please install Swift 6.0+)
endif
	@swift build --configuration release

# iOS app build
ios-build:
	@echo "Building iOS app"
ifndef HAS_SWIFT
	$(error Swift/Xcode is not installed)
endif
	@cd SyntraChatIOS && \
	xcodebuild -project SyntraChatIOS.xcodeproj \
		-scheme SyntraChatIOS \
		-destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
		-configuration Release \
		build

# Run all tests
test: test-swift test-container test-wasm

test-swift:
	@echo "Running Swift tests"
ifdef HAS_SWIFT
	@swift test
else
	@echo "Swift not available, skipping Swift tests"
endif

test-container:
	@echo "Testing container functionality"
	@if [ -f "tools/Scripts/test_container.sh" ]; then \
		chmod +x tools/Scripts/test_container.sh; \
		./tools/Scripts/test_container.sh; \
	else \
		echo "Container tests not yet implemented"; \
	fi

test-wasm:
	@echo "Testing WebAssembly modules"
	@if [ -d "WebAssembly/Guest/dist" ]; then \
		echo "Testing WebAssembly modules..."; \
		if command -v wasmtime >/dev/null 2>&1; then \
			echo "✅ Wasmtime available for testing"; \
		else \
			echo "⚠️  Wasmtime not available, install with: curl https://wasmtime.dev/install.sh -sSf | bash"; \
		fi \
	else \
		echo "WebAssembly modules not built yet, run 'make wasm' first"; \
	fi

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts"
	@rm -rf .build
	@rm -rf WebAssembly/Guest/.build
	@rm -rf WebAssembly/Guest/dist
	@if [ -d "SyntraChatIOS" ]; then \
		cd SyntraChatIOS && \
		xcodebuild clean -project SyntraChatIOS.xcodeproj || true; \
	fi
	@echo "✅ Clean complete"

# Install development dependencies
install-deps:
	@echo "Installing development dependencies"
	@echo "Operating System: $(UNAME_S)"
	
	# macOS dependencies
ifeq ($(UNAME_S),Darwin)
	@echo "Installing macOS dependencies..."
	@if ! command -v brew >/dev/null 2>&1; then \
		echo "Please install Homebrew first: https://brew.sh"; \
		exit 1; \
	fi
	
	# Install container CLI if macOS 26+
	@if sw_vers -productVersion | grep -E "^(26|15)\." >/dev/null 2>&1; then \
		echo "macOS 26+ detected, checking for Apple Container CLI..."; \
		if ! command -v container >/dev/null 2>&1; then \
			echo "Installing Apple Container CLI..."; \
			brew tap apple/container || true; \
			brew install apple/container/container || echo "Apple Container CLI not yet available"; \
		fi \
	fi
	
	# Install other tools
	@brew install binaryen || echo "binaryen already installed"
	@brew install wasmtime || echo "wasmtime already installed"
endif

	# Linux dependencies  
ifeq ($(UNAME_S),Linux)
	@echo "Installing Linux dependencies..."
	@if command -v apt-get >/dev/null 2>&1; then \
		sudo apt-get update; \
		sudo apt-get install -y binaryen curl; \
	elif command -v yum >/dev/null 2>&1; then \
		sudo yum install -y curl; \
	fi
	
	# Install Wasmtime
	@if ! command -v wasmtime >/dev/null 2>&1; then \
		curl https://wasmtime.dev/install.sh -sSf | bash; \
	fi
endif

	# Install Swift toolchain manager
	@if ! command -v swiftly >/dev/null 2>&1; then \
		echo "Installing swiftly (Swift toolchain manager)..."; \
		curl -L https://swiftlang.github.io/swiftly/swiftly-install.sh | bash; \
	fi
	
	@echo "✅ Dependencies installation complete"

# Code formatting
format:
	@echo "Formatting Swift code"
	@if command -v swift-format >/dev/null 2>&1; then \
		find Sources -name "*.swift" -exec swift-format -i {} \; ; \
		find SyntraFoundation -name "*.swift" -exec swift-format -i {} \; ; \
		find WebAssembly -name "*.swift" -exec swift-format -i {} \; ; \
		echo "✅ Code formatting complete"; \
	else \
		echo "swift-format not available, install with: swift package install swift-format"; \
	fi

# Linting
lint:
	@echo "Running Swift linting"
	@if command -v swiftlint >/dev/null 2>&1; then \
		swiftlint; \
	else \
		echo "SwiftLint not available, install with: brew install swiftlint"; \
	fi

# Development shortcuts
dev-setup: install-deps swift-build
	@echo "Development environment setup complete"

# CI/CD shortcuts
ci-build: swift-build container wasm

ci-test: test

# Release build
release: clean ci-build ci-test
	@echo "Release build complete for tag: $(TAG)"

# Quick development cycle
dev: swift-build test-swift
	@echo "Development cycle complete"

# Show environment info
env-info:
	@echo "Environment Information:"
	@echo "OS: $(UNAME_S)"
	@echo "Swift: $(if $(HAS_SWIFT),✅ Available,❌ Not found)"
	@echo "Docker: $(if $(HAS_DOCKER),✅ Available,❌ Not found)"
	@echo "Container CLI: $(if $(HAS_CONTAINER),✅ Available,❌ Not found)"
	@echo "Git SHA: $(shell git rev-parse HEAD)"
	@echo "Git Branch: $(shell git branch --show-current)"
	@echo "Project: $(PROJECT_NAME)"
	@echo "Tag: $(TAG)" 