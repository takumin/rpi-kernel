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

DOWNLOAD_DIR      ?= $(shell realpath ../.dl/dropbear)
SOURCE_DIR        ?= $(shell realpath ../.src/dropbear)
BASE_DIR          ?= /tmp/rpi-kernel/dropbear
BUILD_DIR         ?= $(BASE_DIR)/build
INSTALL_DIR       ?= $(BASE_DIR)/install
ZLIB_DIR          ?= /tmp/rpi-kernel/zlib/install
CROSS_COMPILE     ?= aarch64-linux-gnu-
DROPBEAR_VERSION  ?= 2022.82
DROPBEAR_PROGRAMS ?= dropbear dropbearkey dropbearconvert dbclient scp sftp
DROPBEAR_CFLAGS   ?= -D DROPBEAR_SVR_PASSWORD_AUTH=0
DROPBEAR_LDFLAGS  ?= -Wl,--build-id=none

.PHONY: default
default: install

.PHONY: download
download:
ifeq ($(wildcard $(DOWNLOAD_DIR)/dropbear-$(DROPBEAR_VERSION).tar.bz2),)
	@mkdir -p $(DOWNLOAD_DIR)
	@wget -P $(DOWNLOAD_DIR) https://matt.ucc.asn.au/dropbear/dropbear-$(DROPBEAR_VERSION).tar.bz2
endif

.PHONY: extract
extract: download
ifeq ($(wildcard $(SOURCE_DIR)),)
	@mkdir -p $(SOURCE_DIR)
	@tar -xvf $(DOWNLOAD_DIR)/dropbear-$(DROPBEAR_VERSION).tar.bz2 -C $(SOURCE_DIR) --strip-components=1
endif

.PHONY: configure
configure: extract
ifeq ($(wildcard $(BUILD_DIR)/Makefile),)
	@mkdir -p $(BUILD_DIR)
	@cd $(BUILD_DIR) && \
		CC=$(CROSS_COMPILE)gcc \
		AR=$(CROSS_COMPILE)ar \
		STRIP=$(CROSS_COMPILE)strip \
		RANLIB=$(CROSS_COMPILE)ranlib \
		CFLAGS="$(DROPBEAR_CFLAGS)" \
		LDFLAGS="$(DROPBEAR_LDFLAGS)" \
		$(SOURCE_DIR)/configure \
		--prefix=$(INSTALL_DIR) \
		--build=aarch64-linux-gnu \
		--host=x86_64-linux-gnu \
		--with-zlib=$(ZLIB_DIR) \
		--enable-static
endif

.PHONY: build
build: configure
	@$(MAKE) -j $(shell nproc) -C $(BUILD_DIR) PROGRAMS="$(DROPBEAR_PROGRAMS)" MULTI=1 SCPPROGRESS=1 strip

.PHONY: install
install: build
	@$(MAKE) -j $(shell nproc) -C $(BUILD_DIR) PROGRAMS="$(DROPBEAR_PROGRAMS)" MULTI=1 SCPPROGRESS=1 install
	@ln -fs dropbearmulti $(INSTALL_DIR)/bin/dbclient
	@ln -fs dropbearmulti $(INSTALL_DIR)/bin/dropbearconvert
	@ln -fs dropbearmulti $(INSTALL_DIR)/bin/dropbearkey
	@ln -fs dropbearmulti $(INSTALL_DIR)/bin/scp
	@ln -fs dropbearmulti $(INSTALL_DIR)/bin/sftp
	@ln -fs ../bin/dropbearmulti $(INSTALL_DIR)/sbin/dropbear

.PHONY: clean
clean:
	@rm -fr $(BASE_DIR)
