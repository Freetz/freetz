$(call PKG_INIT_BIN, dnh3.3.2)
$(PKG)_SOURCE:=ctorrent-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.rahul.net/dholmes/ctorrent/
$(PKG)_BINARY:=$($(PKG)_DIR)/ctorrent
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/ctorrent
$(PKG)_SOURCE_MD5:=59b23dd05ff70791cd6449effa7fc3b6

$(PKG)_DEPENDS_ON := uclibcxx

$(PKG)_CONFIGURE_OPTIONS += --with-ssl=no

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)
		
$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(CTORRENT_DIR) all

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(CTORRENT_DIR) clean

$(pkg)-uninstall:
	$(RM) $(CTORRENT_TARGET_BINARY)

$(PKG_FINISH)
