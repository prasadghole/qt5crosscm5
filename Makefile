# ==========================================
# Paths & Files
# ==========================================
BUILD_NATIVE_DIR = build_native
BUILD_PI_DIR = build_pi
TOOLCHAIN_FILE = pi_toolchain.cmake
TARGET = RemoteQtApp
BUILD_TYPE ?= Debug

REMOTE_USER ?= pi
REMOTE_HOST ?=
REMOTE_DIR ?= /home/$(REMOTE_USER)/$(TARGET)
REMOTE_PORT ?= 2345
REMOTE_DISPLAY ?= :0
REMOTE_XDG_RUNTIME_DIR ?= /run/user/1000

IMAGE_NAME = qt5-cross-builder
CONTAINER_WORK_DIR = /workspace

.PHONY: all native pi clean help deploy-pi debug-pi docker-image docker-build-pi docker-build-native

# Default target when you just run 'make'
help:
	@echo "Available local build targets:"
	@echo "  make native             - Build natively for WSL (x86_64)"
	@echo "  make pi                 - Cross-compile for Raspberry Pi CM5 (ARM64)"
	@echo "  make clean              - Remove all build directories"
	@echo "  make deploy-pi REMOTE_HOST=<host> - Copy ARM64 binary to a CM5 over SSH"
	@echo "  make debug-pi REMOTE_HOST=<host>  - Start gdbserver for Qt Creator attach"
	@echo ""
	@echo "Available Docker build targets:"
	@echo "  make docker-image        - Build the Docker cross-compiler image"
	@echo "  make docker-build-native - Compile natively inside Docker container"
	@echo "  make docker-build-pi     - Cross-compile for Pi inside Docker container"

all: native pi

# ==========================================
# Local Compilation Targets
# ==========================================
native:
	@echo "==> Configuring and building natively for WSL (x86_64)..."
	mkdir -p $(BUILD_NATIVE_DIR)
	cd $(BUILD_NATIVE_DIR) && cmake -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) ..
	$(MAKE) -C $(BUILD_NATIVE_DIR) -j$$(nproc)

pi:
	@echo "==> Configuring and cross-compiling for Raspberry Pi CM5 (ARM64)..."
	mkdir -p $(BUILD_PI_DIR)
	cd $(BUILD_PI_DIR) && cmake -DCMAKE_TOOLCHAIN_FILE=../$(TOOLCHAIN_FILE) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) ..
	$(MAKE) -C $(BUILD_PI_DIR) -j$$(nproc)

deploy-pi: pi
	@if [ -z "$(REMOTE_HOST)" ]; then echo "REMOTE_HOST is required, for example: make deploy-pi REMOTE_HOST=cm5.local"; exit 1; fi
	@echo "==> Deploying $(BUILD_PI_DIR)/$(TARGET) to $(REMOTE_USER)@$(REMOTE_HOST):$(REMOTE_DIR)..."
	ssh $(REMOTE_USER)@$(REMOTE_HOST) "mkdir -p $(REMOTE_DIR)"
	rsync -av --chmod=Du=rwx,Dgo=rx,Fu=rwx,Fgo=rx $(BUILD_PI_DIR)/$(TARGET) $(REMOTE_USER)@$(REMOTE_HOST):$(REMOTE_DIR)/$(TARGET)

debug-pi: deploy-pi
	@if [ -z "$(REMOTE_HOST)" ]; then echo "REMOTE_HOST is required, for example: make debug-pi REMOTE_HOST=cm5.local"; exit 1; fi
	@echo "==> Starting gdbserver on $(REMOTE_USER)@$(REMOTE_HOST):$(REMOTE_PORT)..."
	ssh -t $(REMOTE_USER)@$(REMOTE_HOST) "cd $(REMOTE_DIR) && DISPLAY=$(REMOTE_DISPLAY) XDG_RUNTIME_DIR=$(REMOTE_XDG_RUNTIME_DIR) gdbserver :$(REMOTE_PORT) ./$(TARGET)"

clean:
	@echo "==> Cleaning up build folders..."
	rm -rf $(BUILD_NATIVE_DIR) $(BUILD_PI_DIR)
	@echo "==> Done."

# ==========================================
# Docker Automation Targets
# ==========================================
docker-image:
	@echo "==> Building Docker cross-compilation image..."
	docker build -t $(IMAGE_NAME) .

docker-build-pi:
	@echo "==> Compiling for Raspberry Pi inside Docker..."
	docker run --rm -v $(shell pwd):$(CONTAINER_WORK_DIR) $(IMAGE_NAME) make pi BUILD_TYPE=$(BUILD_TYPE)

docker-build-native:
	@echo "==> Compiling natively inside Docker..."
	docker run --rm -v $(shell pwd):$(CONTAINER_WORK_DIR) $(IMAGE_NAME) make native BUILD_TYPE=$(BUILD_TYPE)
