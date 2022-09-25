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

DOWNLOAD_DIR    ?= ../.dl/busybox
SOURCE_DIR      ?= ../.src/busybox
BUILD_DIR       ?= /tmp/rpi-kernel/busybox
CROSS_COMPILE   ?= aarch64-none-linux-gnu-
BUSYBOX_VERSION ?= 1.35.0

.PHONY: default
default: initrd

.PHONY: download
download:
ifeq ($(wildcard $(DOWNLOAD_DIR)/busybox-$(BUSYBOX_VERSION).tar.bz2),)
	@mkdir -p $(DOWNLOAD_DIR)
	@wget -P $(DOWNLOAD_DIR) https://busybox.net/downloads/busybox-$(BUSYBOX_VERSION).tar.bz2
endif

.PHONY: extract
extract: download
ifeq ($(wildcard $(SOURCE_DIR)),)
	@mkdir -p $(SOURCE_DIR)
	@tar -xvf $(DOWNLOAD_DIR)/busybox-$(BUSYBOX_VERSION).tar.bz2 -C $(SOURCE_DIR) --strip-components=1
endif

.PHONY: defconfig
defconfig: extract
ifeq ($(wildcard $(BUILD_DIR)/build/.config),)
	@mkdir -p $(BUILD_DIR)/build
	@$(MAKE) \
		-C $(SOURCE_DIR) \
		-j $(shell nproc) \
		O=$(BUILD_DIR)/build \
		ARCH=arm64 \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		CC="ccache $(CROSS_COMPILE)gcc" \
		CXX="ccache $(CROSS_COMPILE)g++" \
		defconfig
	@sed -i -E 's/.* CONFIG_STATIC .*/CONFIG_STATIC=y/' $(BUILD_DIR)/build/.config
	@sed -i -E 's@CONFIG_PREFIX.*@CONFIG_PREFIX="$(BUILD_DIR)/install"@' $(BUILD_DIR)/build/.config
endif

.PHONY: menuconfig
menuconfig: defconfig
	@$(MAKE) \
		-C $(SOURCE_DIR) \
		-j $(shell nproc) \
		O=$(BUILD_DIR)/build \
		ARCH=arm64 \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		CC="ccache $(CROSS_COMPILE)gcc" \
		CXX="ccache $(CROSS_COMPILE)g++" \
		menuconfig

.PHONY: build
build: defconfig
	@$(MAKE) \
		-C $(SOURCE_DIR) \
		-j $(shell nproc) \
		O=$(BUILD_DIR)/build \
		ARCH=arm64 \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		CC="ccache $(CROSS_COMPILE)gcc" \
		CXX="ccache $(CROSS_COMPILE)g++"

.PHONY: install
install: build
	@$(MAKE) \
		-C $(SOURCE_DIR) \
		-j $(shell nproc) \
		O=$(BUILD_DIR)/build \
		ARCH=arm64 \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		CC="ccache $(CROSS_COMPILE)gcc" \
		CXX="ccache $(CROSS_COMPILE)g++" \
		install

.PHONY: initrd
initrd: install
	@cd $(BUILD_DIR)/install && find . -print0 | cpio -0 -o -R root:root -H newc | gzip -2 -n > $(BUILD_DIR)/rootfs.cpio.gz
	@advdef -z4 $(BUILD_DIR)/rootfs.cpio.gz

.PHONY: clean
clean:
	@rm -fr $(BUILD_DIR)
