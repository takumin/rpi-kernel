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

DOWNLOAD_DIR  ?= ../.dl/linux
SOURCE_DIR    ?= ../.src/linux
BUILD_DIR     ?= /tmp/rpi-kernel/linux
CROSS_COMPILE ?= aarch64-none-linux-gnu-
LINUX_BRANCH  ?= rpi-5.15.y

.PHONY: default
default: bindeb-pkg distribution

.PHONY: download
download:
ifeq ($(wildcard $(DOWNLOAD_DIR)/$(LINUX_BRANCH).tar.gz),)
	@mkdir -p $(DOWNLOAD_DIR)
	@wget -P $(DOWNLOAD_DIR) https://github.com/raspberrypi/linux/archive/refs/heads/$(LINUX_BRANCH).tar.gz
endif

.PHONY: extract
extract: download
ifeq ($(wildcard $(SOURCE_DIR)/$(LINUX_BRANCH)/Makefile),)
	@mkdir -p $(SOURCE_DIR)/$(LINUX_BRANCH)
	@tar -xvf $(DOWNLOAD_DIR)/$(LINUX_BRANCH).tar.gz -C $(SOURCE_DIR)/$(LINUX_BRANCH) --strip-components=1
endif

.PHONY: defconfig
defconfig: extract
ifeq ($(wildcard $(BUILD_DIR)/build/.config),)
	@$(MAKE) \
		-C $(SOURCE_DIR)/$(LINUX_BRANCH) \
		-j $(shell nproc) \
		O=$(BUILD_DIR)/build \
		ARCH=arm64 \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		CC="ccache $(CROSS_COMPILE)gcc" \
		CXX="ccache $(CROSS_COMPILE)g++" \
		KBUILD_BUILD_TIMESTAMP='' \
		bcm2711_defconfig
	@sed -i -E 's@.* CONFIG_EFI_GENERIC_STUB_INITRD_CMDLINE_LOADER .*@CONFIG_EFI_GENERIC_STUB_INITRD_CMDLINE_LOADER=y@' $(BUILD_DIR)/build/.config
endif

.PHONY: menuconfig
menuconfig: defconfig
	@$(MAKE) \
		-C $(SOURCE_DIR)/$(LINUX_BRANCH) \
		-j $(shell nproc) \
		O=$(BUILD_DIR)/build \
		ARCH=arm64 \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		CC="ccache $(CROSS_COMPILE)gcc" \
		CXX="ccache $(CROSS_COMPILE)g++" \
		KBUILD_BUILD_TIMESTAMP='' \
		menuconfig

.PHONY: xconfig
xconfig: defconfig
	@$(MAKE) \
		-C $(SOURCE_DIR)/$(LINUX_BRANCH) \
		-j $(shell nproc) \
		O=$(BUILD_DIR)/build \
		ARCH=arm64 \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		CC="ccache $(CROSS_COMPILE)gcc" \
		CXX="ccache $(CROSS_COMPILE)g++" \
		KBUILD_BUILD_TIMESTAMP='' \
		xconfig

.PHONY: gconfig
gconfig: defconfig
	@$(MAKE) \
		-C $(SOURCE_DIR)/$(LINUX_BRANCH) \
		-j $(shell nproc) \
		O=$(BUILD_DIR)/build \
		ARCH=arm64 \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		CC="ccache $(CROSS_COMPILE)gcc" \
		CXX="ccache $(CROSS_COMPILE)g++" \
		KBUILD_BUILD_TIMESTAMP='' \
		gconfig

.PHONY: build
build: defconfig
	@$(MAKE) \
		-C $(SOURCE_DIR)/$(LINUX_BRANCH) \
		-j $(shell nproc) \
		O=$(BUILD_DIR)/build \
		ARCH=arm64 \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		CC="ccache $(CROSS_COMPILE)gcc" \
		CXX="ccache $(CROSS_COMPILE)g++" \
		KBUILD_BUILD_TIMESTAMP=''

.PHONY: bindeb-pkg
bindeb-pkg: build
	@$(MAKE) \
		-C $(SOURCE_DIR)/$(LINUX_BRANCH) \
		-j $(shell nproc) \
		O=$(BUILD_DIR)/build \
		ARCH=arm64 \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		CC="ccache $(CROSS_COMPILE)gcc" \
		CXX="ccache $(CROSS_COMPILE)g++" \
		KBUILD_BUILD_TIMESTAMP='' \
		bindeb-pkg

.PHONY: distribution
distribution: build
	@mkdir -p $(BUILD_DIR)/boot
	@$(MAKE) \
		-C $(SOURCE_DIR)/$(LINUX_BRANCH) \
		-j $(shell nproc) \
		O=$(BUILD_DIR)/build \
		ARCH=arm64 \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		CC="ccache $(CROSS_COMPILE)gcc" \
		CXX="ccache $(CROSS_COMPILE)g++" \
		KBUILD_BUILD_TIMESTAMP='' \
		INSTALL_MOD_PATH=$(BUILD_DIR)/modules \
		INSTALL_HDR_PATH=$(BUILD_DIR)/headers \
		INSTALL_DTBS_PATH=$(BUILD_DIR)/boot \
		INSTALL_PATH=$(BUILD_DIR)/boot \
		zinstall modules_install headers_install dtbs_install

.PHONY: clean
clean:
	@rm -fr $(BUILD_DIR)
