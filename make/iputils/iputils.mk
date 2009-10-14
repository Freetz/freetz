$(call PKG_INIT_BIN, s20071127)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://www.skbuff.net/iputils
$(PKG)_BINARY:=$($(PKG)_DIR)/traceroute6
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/traceroute6
$(PKG)_SOURCE_MD5:=12245e9927d60ff5cf4a99d265bcb7d3 


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)


$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(IPUTILS_DIR) traceroute6 tracepath6 tracepath ping ping6 \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"
		
		
$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(IPUTILS_DIR) clean

$(pkg)-uninstall:
	$(RM) $($(PKG)_TARGET_BINARY)

$(PKG_FINISH)
