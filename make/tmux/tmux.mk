$(call PKG_INIT_BIN, 2.5)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=ae135ec37c1bf6b7750a84e3a35e93d91033a806943e034521c8af51b12d95df
$(PKG)_SITE:=https://github.com/$(pkg)/$(pkg)/releases/download/$($(PKG)_VERSION)

$(PKG)_BINARY:=$($(PKG)_DIR)/tmux
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/tmux

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TMUX_STATIC

$(PKG)_DEPENDS_ON += ncurses libevent

# touch configure.ac to prevent aclocal.m4 & configure from being regenerated
$(PKG)_PATCH_POST_CMDS += touch -t 200001010000.00 configure.ac;

$(PKG)_CONFIGURE_ENV += ac_cv_search_event_init="-lpthread -levent"
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_TMUX_STATIC),--enable-static)

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
