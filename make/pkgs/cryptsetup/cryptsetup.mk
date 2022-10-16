$(call PKG_INIT_BIN, 1.7.5)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=2b30cd1d0dd606a53ac77b406e1d37798d4b0762fa89de6ea546201906a251bd
$(PKG)_SITE:=@KERNEL/linux/utils/cryptsetup/v$(call GET_MAJOR_VERSION,$($(PKG)_VERSION))

$(PKG)_BINARY:=$($(PKG)_DIR)/src/cryptsetup
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/cryptsetup

$(PKG)_DEPENDS_ON += devmapper e2fsprogs popt libgcrypt

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --with-gnu-ld
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --disable-kernel_crypto
$(PKG)_CONFIGURE_OPTIONS += --with-crypto_backend=gcrypt
$(PKG)_CONFIGURE_OPTIONS += --disable-python

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(CRYPTSETUP_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(CRYPTSETUP_DIR) clean

$(pkg)-uninstall:
	$(RM) $(CRYPTSETUP_TARGET_BINARY)

$(PKG_FINISH)
