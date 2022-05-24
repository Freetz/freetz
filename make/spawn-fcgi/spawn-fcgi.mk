$(call PKG_INIT_BIN, 1.6.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=e6721dc0fa59bb00e05f160406815d53c95e81ac28f7e52fbd36497584f846cd
$(PKG)_SITE:=http://www.lighttpd.net/download
$(PKG)_BINARY:=$($(PKG)_DIR)/src/spawn-fcgi
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/spawn-fcgi

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SPAWN_FCGI_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SPAWN_FCGI_DIR) clean

$(pkg)-uninstall:
	$(RM) $(SPAWN_FCGI_TARGET_BINARY)

$(PKG_FINISH)
