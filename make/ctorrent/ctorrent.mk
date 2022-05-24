$(call PKG_INIT_BIN, dnh3.3.2)
$(PKG)_SOURCE:=ctorrent-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=c87366c91475931f75b924119580abd06a7b3cb3f00fef47346552cab1e24863
$(PKG)_SITE:=http://www.rahul.net/dholmes/ctorrent/

$(PKG)_BINARY:=$($(PKG)_DIR)/ctorrent
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/ctorrent

$(PKG)_DEPENDS_ON += $(STDCXXLIB)
$(PKG)_REBUILD_SUBOPTS += FREETZ_STDCXXLIB

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
