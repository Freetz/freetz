$(call PKG_INIT_BIN, v8.1.1491)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SITE:=git@https://github.com/vim/vim.git

$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_DEPENDS_ON += ncurses

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_VIM_TINY
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_VIM_NORMAL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_VIM_HUGE

$(PKG)_CONFIGURE_ENV += vim_cv_getcwd_broken=no
$(PKG)_CONFIGURE_ENV += vim_cv_memmove_handles_overlap=yes
$(PKG)_CONFIGURE_ENV += vim_cv_stat_ignores_slash=yes
$(PKG)_CONFIGURE_ENV += vim_cv_tgetent=zero
$(PKG)_CONFIGURE_ENV += vim_cv_terminfo=yes
$(PKG)_CONFIGURE_ENV += vim_cv_toupper_broken=no
$(PKG)_CONFIGURE_ENV += vim_cv_tty_group=root
$(PKG)_CONFIGURE_ENV += vim_cv_tty_mode=0620

$(PKG)_CONFIGURE_OPTIONS += --with-features=$(if $(FREETZ_PACKAGE_VIM_HUGE),huge,$(if $(FREETZ_PACKAGE_VIM_NORMAL),normal,tiny))
$(PKG)_CONFIGURE_OPTIONS += --enable-multibyte

$(PKG)_CONFIGURE_OPTIONS += --disable-gui
$(PKG)_CONFIGURE_OPTIONS += --disable-gtktest
$(PKG)_CONFIGURE_OPTIONS += --disable-xim
$(PKG)_CONFIGURE_OPTIONS += --without-x
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
