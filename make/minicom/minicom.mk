$(call PKG_INIT_BIN,2.4)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://alioth.debian.org/frs/download.php/3195
$(PKG)_BINARY:=$($(PKG)_DIR)/src/minicom
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/minicom
$(PKG)_SOURCE_MD5:=700976a3c2dcc8bbd50ab9bb1c08837b

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(MINICOM_DIR) \
		AM_CFLAGS=""

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(MINICOM_DIR) clean

$(pkg)-uninstall:
	$(RM) $(MINICOM_TARGET_BINARY)

$(PKG_FINISH)
