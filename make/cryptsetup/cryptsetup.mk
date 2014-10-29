$(call PKG_INIT_BIN, 1.6.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=99002ac59a65ea371e7a98200943cb80
$(PKG)_SITE:=http://cryptsetup.googlecode.com/files

$(PKG)_BINARY:=$($(PKG)_DIR)/src/cryptsetup
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/cryptsetup

$(PKG)_DEPENDS_ON += devmapper e2fsprogs popt libgcrypt
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_E2FSPROGS_STATIC

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
