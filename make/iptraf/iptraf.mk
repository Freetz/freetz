$(call PKG_INIT_BIN, 3.0.0)
$(PKG)_SOURCE:=iptraf-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=ftp://iptraf.seul.org/pub/iptraf
$(PKG)_BINARY:=$($(PKG)_DIR)/src/iptraf
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/iptraf
$(PKG)_SOURCE_MD5:=377371c28ee3c21a76f7024920649ea8

$(PKG)_DEPENDS_ON := ncurses

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(IPTRAF_DIR)/src \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		INCLUDEDIR="-I../support"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(IPTRAF_DIR)/src clean
	$(RM) $(IPTRAF_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(IPTRAF_TARGET_BINARY)

$(PKG_FINISH)
