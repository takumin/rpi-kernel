unexport CPATH
unexport C_INCLUDE_PATH
unexport CPLUS_INCLUDE_PATH
unexport PKG_CONFIG_PATH
unexport CMAKE_MODULE_PATH
unexport CCACHE_PATH
unexport LD_LIBRARY_PATH
unexport LD_RUN_PATH
unexport UNZIP

export LC_ALL = C
export CCACHE_DIR = $(HOME)/.cache/rpi-kernel

DOWNLOAD_DIR         ?= $(shell realpath ../.dl/ignition)
SOURCE_DIR           ?= $(shell realpath ../.src/ignition)
BASE_DIR             ?= /tmp/rpi-kernel/ignition
BUILD_DIR            ?= $(BASE_DIR)/build
INSTALL_DIR          ?= $(BASE_DIR)/install
CROSS_COMPILE        ?= aarch64-linux-gnu-
IGNITION_REPOSITORY  ?= github.com/coreos/ignition
IGNITION_VERSION     ?= 2.14.0
IGNITION_TAGS        ?= netgo osusergo
IGNITION_LDFLAGS     ?= -s -w -buildid=
IGNITION_LDFLAGS     += -X $(IGNITION_REPOSITORY)/v2/internal/version.Raw=$(IGNITION_VERSION)
# IGNITION_LDFLAGS     += -extldflags -static
IGNITION_CGO_LDFLAGS ?= -g -O2 -Wl,--build-id=none

.PHONY: default
default: install

.PHONY: download
download:
ifeq ($(wildcard $(DOWNLOAD_DIR)/v$(IGNITION_VERSION).tar.gz),)
	@mkdir -p $(DOWNLOAD_DIR)
	@wget -P $(DOWNLOAD_DIR) https://$(IGNITION_REPOSITORY)/archive/refs/tags/v$(IGNITION_VERSION).tar.gz
endif

.PHONY: extract
extract: download
ifeq ($(wildcard $(SOURCE_DIR)),)
	@mkdir -p $(SOURCE_DIR)
	@tar -xvf $(DOWNLOAD_DIR)/v$(IGNITION_VERSION).tar.gz -C $(SOURCE_DIR) --strip-components=1
endif

.PHONY: build
build: extract
	@cd $(SOURCE_DIR) && \
		GOARCH=arm64 \
		CGO_ENABLED=1 \
		GO111MODULE=on \
		AR=$(CROSS_COMPILE)ar \
		CC=$(CROSS_COMPILE)gcc \
		CXX=$(CROSS_COMPILE)g++ \
		CGO_LDFLAGS="$(IGNITION_CGO_LDFLAGS)" \
		go build -v \
		-trimpath \
		-mod=vendor \
		-tags "$(IGNITION_TAGS)" \
		-ldflags "${IGNITION_LDFLAGS}" \
		-o $(BUILD_DIR)/ignition \
		$(IGNITION_REPOSITORY)/v2/internal
	@cd $(SOURCE_DIR) && \
		GOARCH=arm64 \
		CGO_ENABLED=0 \
		GO111MODULE=on \
		AR=$(CROSS_COMPILE)ar \
		CC=$(CROSS_COMPILE)gcc \
		CXX=$(CROSS_COMPILE)g++ \
		CGO_LDFLAGS="$(IGNITION_CGO_LDFLAGS)" \
		go build -v \
		-trimpath \
		-mod=vendor \
		-tags "$(IGNITION_TAGS)" \
		-ldflags "${IGNITION_LDFLAGS}" \
		-o $(BUILD_DIR)/ignition-validate \
		$(IGNITION_REPOSITORY)/v2/validate

.PHONY: install
install: build
	@mkdir -p $(INSTALL_DIR)
	@install -m 0755 $(BUILD_DIR)/ignition $(INSTALL_DIR)/ignition
	@install -m 0755 $(BUILD_DIR)/ignition-validate $(INSTALL_DIR)/ignition-validate
	@install -m 0755 $(SOURCE_DIR)/dracut/30ignition/ignition-kargs-helper.sh $(INSTALL_DIR)/ignition-kargs-helper
	@install -m 0755 $(SOURCE_DIR)/dracut/30ignition/ignition-generator $(INSTALL_DIR)/
	@install -m 0644 $(SOURCE_DIR)/dracut/30ignition/*.service $(INSTALL_DIR)/
	@install -m 0644 $(SOURCE_DIR)/dracut/30ignition/*.target $(INSTALL_DIR)/
	@install -m 0644 $(SOURCE_DIR)/dracut/30ignition/*.rules $(INSTALL_DIR)/

.PHONY: clean
clean:
	@rm -fr $(BASE_DIR)
