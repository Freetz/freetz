$(call PKG_INIT_BIN, 3.3a)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=e4fd347843bd0772c4f48d6dde625b0b109b7a380ff15db21e97c11a4dcdf93f
$(PKG)_SITE:=https://github.com/$(pkg)/$(pkg)/releases/download/$($(PKG)_VERSION)
### WEBSITE:=https://tmux.github.io
### MANPAGE:=http://man.openbsd.org/OpenBSD-current/man1/tmux.1
### CHANGES:=https://github.com/tmux/tmux/blob/master/CHANGES
### CVSREPO:=https://github.com/tmux/tmux

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
