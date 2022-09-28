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
BASE_DIR        ?= /tmp/rpi-kernel/busybox
BUILD_DIR       ?= $(BASE_DIR)/build
INSTALL_DIR     ?= $(BASE_DIR)/install
MODULES_DIR     ?= /tmp/rpi-kernel/linux/modules
DROPBEAR_DIR    ?= /tmp/rpi-kernel/dropbear/install
CROSS_COMPILE   ?= aarch64-linux-gnu-
BUSYBOX_VERSION ?= 1.35.0

.PHONY: default
default: initrd.gz initrd.xz

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
ifeq ($(wildcard $(BUILD_DIR)/.config),)
	@mkdir -p $(BUILD_DIR)
	@$(MAKE) \
		-C $(SOURCE_DIR) \
		-j $(shell nproc) \
		O=$(BUILD_DIR) \
		ARCH=arm64 \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		CC="ccache $(CROSS_COMPILE)gcc" \
		CXX="ccache $(CROSS_COMPILE)g++" \
		defconfig
	@sed -i -E 's/.* CONFIG_STATIC .*/CONFIG_STATIC=y/' $(BUILD_DIR)/.config
	@sed -i -E 's@CONFIG_PREFIX.*@CONFIG_PREFIX="$(INSTALL_DIR)"@' $(BUILD_DIR)/.config
endif

.PHONY: menuconfig
menuconfig: defconfig
	@$(MAKE) \
		-C $(SOURCE_DIR) \
		-j $(shell nproc) \
		O=$(BUILD_DIR) \
		ARCH=arm64 \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		CC="ccache $(CROSS_COMPILE)gcc" \
		CXX="ccache $(CROSS_COMPILE)g++" \
		menuconfig

.PHONY: build
build: defconfig
ifeq ($(wildcard $(BUILD_DIR)/busybox),)
	@$(MAKE) \
		-C $(SOURCE_DIR) \
		-j $(shell nproc) \
		O=$(BUILD_DIR) \
		ARCH=arm64 \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		CC="ccache $(CROSS_COMPILE)gcc" \
		CXX="ccache $(CROSS_COMPILE)g++"
endif

.PHONY: install
install: build
ifeq ($(wildcard $(INSTALL_DIR)/bin/busybox),)
	@$(MAKE) \
		-C $(SOURCE_DIR) \
		-j $(shell nproc) \
		O=$(BUILD_DIR) \
		ARCH=arm64 \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		CC="ccache $(CROSS_COMPILE)gcc" \
		CXX="ccache $(CROSS_COMPILE)g++" \
		install
endif

.PHONY: script
script: install
	@rsync -a $(MODULES_DIR)/lib/ $(INSTALL_DIR)/lib/
	@rsync -a $(DROPBEAR_DIR)/bin/ $(INSTALL_DIR)/bin/
	@rsync -a $(DROPBEAR_DIR)/sbin/ $(INSTALL_DIR)/sbin/
	@cp init $(INSTALL_DIR)/init
	@chmod +x $(INSTALL_DIR)/init

.PHONY: initrd.gz
initrd.gz: script
	@cd $(INSTALL_DIR) && find . -print0 | cpio -0 -o -R root:root -H newc | pigz -n > $(BASE_DIR)/initramfs.cpio.gz

.PHONY: initrd.xz
initrd.xz: script
	@cd $(INSTALL_DIR) && find . -print0 | cpio -0 -o -R root:root -H newc | pixz > $(BASE_DIR)/initramfs.cpio.xz

.PHONY: clean
clean:
	@rm -fr $(BASE_DIR)
