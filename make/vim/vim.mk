$(call PKG_INIT_BIN, 7.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=5b9510a17074e2b37d8bb38ae09edbf2
$(PKG)_SITE:=ftp://ftp.vim.org/pub/vim/unix

$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/$(pkg)73

$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_DEPENDS_ON := ncurses

$(PKG)_CONFIGURE_ENV += vim_cv_getcwd_broken=no
$(PKG)_CONFIGURE_ENV += vim_cv_memmove_handles_overlap=yes
$(PKG)_CONFIGURE_ENV += vim_cv_stat_ignores_slash=yes
$(PKG)_CONFIGURE_ENV += vim_cv_tgetent=zero
$(PKG)_CONFIGURE_ENV += vim_cv_terminfo=yes
$(PKG)_CONFIGURE_ENV += vim_cv_toupper_broken=no
$(PKG)_CONFIGURE_ENV += vim_cv_tty_group=root
$(PKG)_CONFIGURE_ENV += vim_cv_tty_mode=0620

$(PKG)_CONFIGURE_OPTIONS += --disable-gui
$(PKG)_CONFIGURE_OPTIONS += --disable-gtktest
$(PKG)_CONFIGURE_OPTIONS += --disable-xim
ifeq ($(strip $(FREETZ_PACKAGE_VIM_HUGE)),y)
$(PKG)_CONFIGURE_OPTIONS += --with-features=huge
else
ifeq ($(strip $(FREETZ_PACKAGE_VIM_NORMAL)),y)
$(PKG)_CONFIGURE_OPTIONS += --with-features=normal
else
$(PKG)_CONFIGURE_OPTIONS += --with-features=tiny
endif
endif
$(PKG)_CONFIGURE_OPTIONS += --without-x
$(PKG)_CONFIGURE_OPTIONS += --disable-multibyte
$(PKG)_CONFIGURE_OPTIONS += --disable-netbeans
$(PKG)_CONFIGURE_OPTIONS += --disable-gpm
$(PKG)_CONFIGURE_OPTIONS += --with-tlib=ncurses

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(VIM_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(VIM_DIR) clean

$(pkg)-uninstall:
	$(RM) $(VIM_TARGET_BINARY)

$(PKG_FINISH)
