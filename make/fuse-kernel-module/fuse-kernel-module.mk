$(call PKG_INIT_BIN, 2.7.6)
$(PKG)_SOURCE:=fuse-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=319f12dffd6f7073628fefc980254f4a
$(PKG)_SITE:=https://github.com/libfuse/libfuse/releases/download/fuse_2_9_4

$(PKG)_TARBALL_STRIP_COMPONENTS:=2
$(PKG)_TARBALL_INCLUDE_FILTER:=fuse-$($(PKG)_VERSION)/kernel

$(PKG)_BINARY:=$($(PKG)_DIR)/fuse.ko
$(PKG)_TARGET_DIR:=$(KERNEL_MODULES_DIR)/fs/fuse
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/fuse.ko

$(PKG)_DEPENDS_ON += kernel

$(PKG)_REBUILD_SUBOPTS += FREETZ_KERNEL_LAYOUT

$(PKG)_CONFIGURE_OPTIONS += --enable-kernel-module
$(PKG)_CONFIGURE_OPTIONS += --with-kernel="$(FREETZ_BASE_DIR)/$(KERNEL_SOURCE_DIR)"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(FUSE_KERNEL_MODULE_DIR) \
		ARCH="$(KERNEL_ARCH)" \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		V=1 \
		all

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(FUSE_KERNEL_MODULE_DIR) clean

$(pkg)-uninstall:
	$(RM) $(FUSE_KERNEL_MODULE_TARGET_BINARY)

$(PKG_FINISH)
