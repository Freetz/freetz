$(call PKG_INIT_BIN, 1.6)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=3e37db24aa596bf108a0442a81c845b3
$(PKG)_SITE:=@SF/$(pkg)

$(PKG)_BINARY:=$($(PKG)_DIR)/tmux
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/tmux

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TMUX_STATIC

$(PKG)_DEPENDS_ON := ncurses libevent

$(PKG)_CONFIGURE_ENV += ac_cv_search_event_init="-lpthread -levent"
$(PKG)_CONFIGURE_OPTIONS += --enable-static=$(if $(FREETZ_PACKAGE_TMUX_STATIC),yes,no)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(TMUX_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(TMUX_DIR) clean
	$(RM) $(TMUX_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(TMUX_TARGET_BINARY)

$(PKG_FINISH)
