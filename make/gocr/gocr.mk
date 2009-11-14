$(call PKG_INIT_BIN, 0.48)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www-e.uni-magdeburg.de/jschulen/ocr/
$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)
$(PKG)_SOURCE_MD5:=9882ba9a93fcb18ab704a10da80c228c

$(PKG)_DEPENDS_ON := netpbm

$(PKG)_CONFIGURE_OPTIONS += --with-netpbm="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(GOCR_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(GOCR_DIR) clean

$(pkg)-uninstall:
	$(RM) $(GOCR_TARGET_BINARY)

$(PKG_FINISH)
