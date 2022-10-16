$(call PKG_INIT_BIN, 0.49)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=cc29931d50b3be11608dc79d1c7d8a20919dbe6313b1ba5dc88ecf99cffd171a
$(PKG)_SITE:=http://www-e.uni-magdeburg.de/jschulen/ocr

$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_DEPENDS_ON += netpbm

$(PKG)_CONFIGURE_OPTIONS += --with-netpbm="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(GOCR_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(GOCR_DIR) clean

$(pkg)-uninstall:
	$(RM) $(GOCR_TARGET_BINARY)

$(PKG_FINISH)
