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

MODULES_DIR ?= /tmp/rpi-kernel/linux/modules
ROOTFS_DIR  ?= /tmp/rpi-kernel/ubuntu/rootfs
BUILD_DIR   ?= /tmp/rpi-kernel/archive

.PHONY: default
default: initrd.gz initrd.xz

.PHONY: rootfs
rootfs:
	@mkdir -p $(BUILD_DIR)
	@sudo cp -r $(ROOTFS_DIR) $(BUILD_DIR)/rootfs
	@sudo cp -r $(MODULES_DIR)/lib/modules $(BUILD_DIR)/rootfs/lib/modules

.PHONY: initrd.gz
initrd.gz: rootfs
	@cd $(BUILD_DIR)/rootfs && sudo find . -print0 | sudo cpio -0 -o -R root:root -H newc | pigz -n > $(BUILD_DIR)/rootfs.cpio.gz

.PHONY: initrd.xz
initrd.xz: rootfs
	@cd $(BUILD_DIR)/rootfs && sudo find . -print0 | sudo cpio -0 -o -R root:root -H newc | pixz > $(BUILD_DIR)/rootfs.cpio.xz

.PHONY: clean
clean:
	@sudo rm -fr $(BUILD_DIR)
