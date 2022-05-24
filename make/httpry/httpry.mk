$(call PKG_INIT_BIN, 0.1.8)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=ef53454f895f68005f7b9ab634d1b433c4df839eacea9109e4ee48d4296fb613
$(PKG)_SITE:=http://dumpsterventures.com/jason/$(pkg)

$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_DEPENDS_ON += libpcap

$(PKG)_EXCLUDED+=$(if $(FREETZ_PACKAGE_HTTPRY_REMOVE_WEBIF),etc/default.httpry etc/init.d/rc.httpry usr/lib/cgi-bin/httpry.cgi usr/lib/cgi-bin/httpry)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(HTTPRY_DIR) \
		CC="$(TARGET_CC)" \
		CCFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(HTTPRY_DIR) clean

$(pkg)-uninstall:
	$(RM) $(HTTPRY_TARGET_BINARY)

$(PKG_FINISH)
