$(call PKG_INIT_BIN, 3.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=ftp://ftp.gnu.org/pub/gnu/httptunnel
$(PKG)_BINARY:=$($(PKG)_DIR)/hts
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/hts

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(HTTPTUNNEL_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(HTTPTUNNEL_DIR) clean

$(pkg)-uninstall:
	$(RM) $(HTTPTUNNEL_TARGET_BINARY)

$(PKG_FINISH)
