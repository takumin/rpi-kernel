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

DOWNLOAD_DIR  ?= $(shell realpath ../.dl/zlib)
SOURCE_DIR    ?= $(shell realpath ../.src/zlib)
BASE_DIR      ?= /tmp/rpi-kernel/zlib
BUILD_DIR     ?= $(BASE_DIR)/build
INSTALL_DIR   ?= $(BASE_DIR)/install
CROSS_COMPILE ?= aarch64-linux-gnu-
ZLIB_VERSION  ?= 1.2.12

.PHONY: default
default: install

.PHONY: download
download:
ifeq ($(wildcard $(DOWNLOAD_DIR)/zlib-$(ZLIB_VERSION).tar.gz),)
	@mkdir -p $(DOWNLOAD_DIR)
	@wget -P $(DOWNLOAD_DIR) https://zlib.net/zlib-$(ZLIB_VERSION).tar.gz
endif

.PHONY: extract
extract: download
ifeq ($(wildcard $(SOURCE_DIR)),)
	@mkdir -p $(SOURCE_DIR)
	@tar -xvf $(DOWNLOAD_DIR)/zlib-$(ZLIB_VERSION).tar.gz -C $(SOURCE_DIR) --strip-components=1
endif

.PHONY: configure
configure: extract
ifeq ($(wildcard $(BUILD_DIR)/Makefile),)
	@mkdir -p $(BUILD_DIR)
	@cd $(BUILD_DIR) && \
		CC=$(CROSS_COMPILE)gcc \
		CXX=$(CROSS_COMPILE)g++ \
		$(SOURCE_DIR)/configure \
		--prefix=$(INSTALL_DIR) \
		--static
endif

.PHONY: build
build: configure
	@$(MAKE) -j $(shell nproc) -C $(BUILD_DIR)

.PHONY: install
install: build
	@$(MAKE) -j $(shell nproc) -C $(BUILD_DIR) install

.PHONY: clean
clean:
	@rm -fr $(BASE_DIR)
