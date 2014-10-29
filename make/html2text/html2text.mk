$(call PKG_INIT_BIN, 1.3.2a)
$(PKG)_SOURCE:=html2text-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=6097fe07b948e142315749e6620c9cfc
$(PKG)_SITE:=http://www.mbayer.de/html2text/downloads

$(PKG)_BINARY:=$($(PKG)_DIR)/html2text
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/html2text

$(PKG)_DEPENDS_ON += $(STDCXXLIB)

$(PKG)_REBUILD_SUBOPTS += FREETZ_STDCXXLIB

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(HTML2TEXT_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(HTML2TEXT_DIR) clean
	$(RM) $(HTML2TEXT_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(HTML2TEXT_TARGET_BINARY)

$(PKG_FINISH)
