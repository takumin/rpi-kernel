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

BUILD_DIR      ?= /tmp/rpi-kernel/ubuntu
MODULES_DIR    ?= /tmp/rpi-kernel/linux/modules
APT_MIRROR_URL ?= http://proxy.apt.internal:3142/ubuntu-ports
ARCHITECTURES  ?= arm64
VARIANT        ?= apt
SUITE          ?= jammy
COMPONENTS     ?= main,restricted,universe,multiverse

# packages
INCLUDE_PACKAGES ?=
# base
INCLUDE_PACKAGES += linux-base
INCLUDE_PACKAGES += util-linux
# kernel
INCLUDE_PACKAGES += kmod
# firmware
INCLUDE_PACKAGES += linux-firmware
INCLUDE_PACKAGES += linux-firmware-raspi
# archive
INCLUDE_PACKAGES += xz-utils
# web
INCLUDE_PACKAGES += ca-certificates
INCLUDE_PACKAGES += curl
INCLUDE_PACKAGES += wget
# security
INCLUDE_PACKAGES += sudo
INCLUDE_PACKAGES += policykit-1
INCLUDE_PACKAGES += openssh-server
# systemd
INCLUDE_PACKAGES += init
INCLUDE_PACKAGES += dbus
INCLUDE_PACKAGES += dbus-user-session
INCLUDE_PACKAGES += systemd
INCLUDE_PACKAGES += systemd-sysv
INCLUDE_PACKAGES += systemd-timesyncd
INCLUDE_PACKAGES += libpam-systemd
INCLUDE_PACKAGES += libnss-systemd
# timezone
INCLUDE_PACKAGES += tzdata
# networking
INCLUDE_PACKAGES += ethtool
INCLUDE_PACKAGES += iproute2
INCLUDE_PACKAGES += iputils-ping
INCLUDE_PACKAGES += netbase
INCLUDE_PACKAGES += netcat-openbsd
# tuning
INCLUDE_PACKAGES += irqbalance
# utils
INCLUDE_PACKAGES += bash-completion
INCLUDE_PACKAGES += htop
INCLUDE_PACKAGES += less
INCLUDE_PACKAGES += lsof
INCLUDE_PACKAGES += patch
INCLUDE_PACKAGES += vim-tiny

.PHONY: default
default: rootfs.tar.gz rootfs.tar.xz

.PHONY: rootfs
rootfs:
	@mkdir -p $(BUILD_DIR)
	@sudo mmdebstrap \
		--variant='$(VARIANT)' \
		--components='$(COMPONENTS)' \
		--architectures='$(ARCHITECTURES)' \
		--include='$(INCLUDE_PACKAGES)' \
		--dpkgopt='path-exclude=/usr/share/gnome/help/*' \
		--dpkgopt='path-exclude=/usr/share/help/*' \
		--dpkgopt='path-exclude=/usr/share/info/*' \
		--dpkgopt='path-exclude=/usr/share/locale/*' \
		--dpkgopt='path-exclude=/usr/share/lintian/*' \
		--dpkgopt='path-exclude=/usr/share/man/*' \
		--dpkgopt='path-exclude=/usr/share/omf/*' \
		--dpkgopt='path-exclude=/usr/share/doc/*' \
		--dpkgopt='path-include=/usr/share/doc/*/copyright' \
		--dpkgopt='path-include=/usr/share/doc/*/changelog.Debian.*' \
		--customize-hook='ln -sf "../run/systemd/resolve/stub-resolv.conf" "$$1/etc/resolv.conf"' \
		--customize-hook='echo "127.0.0.1 localhost.localdomain localhost" > "$$1/etc/hosts"' \
		--customize-hook='echo "localhost" > "$$1/etc/hostname"' \
		--customize-hook='rm -f "$$1/var/lib/dbus/machine-id"' \
		--customize-hook='rm -f "$$1/etc/machine-id"' \
		--customize-hook='touch "$$1/var/lib/dbus/machine-id"' \
		--customize-hook='touch "$$1/etc/machine-id"' \
		--customize-hook='cp -r $(MODULES_DIR)/lib/modules "$$1/lib/modules"' \
		--hook-directory='/usr/share/mmdebstrap/hooks/merged-usr' \
		'$(SUITE)' '$(BUILD_DIR)/rootfs' '$(APT_MIRROR_URL)'

.PHONY: rootfs.tar.gz
rootfs.tar.gz: rootfs
	@sudo tar -I pigz -p --acls --xattrs --one-file-system -cf $(BUILD_DIR)/rootfs.tar.gz -C $(BUILD_DIR)/rootfs .

.PHONY: rootfs.tar.xz
rootfs.tar.xz: rootfs
	@sudo tar -I pixz -p --acls --xattrs --one-file-system -cf $(BUILD_DIR)/rootfs.tar.xz -C $(BUILD_DIR)/rootfs .

.PHONY: clean
clean:
	@sudo rm -fr $(BUILD_DIR)
