$(call PKG_INIT_BIN, 4.9.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=f9335281bb4d1538ed078df78a20c2f39d3af9a4e91c57d084271e0289c730f4
$(PKG)_SITE:=@GNU/$(pkg)
### WEBSITE:=https://www.gnu.org/software/screen/
### MANPAGE:=https://www.gnu.org/software/screen/manual/
### CHANGES:=https://git.savannah.gnu.org/cgit/screen.git/refs/
### CVSREPO:=https://git.savannah.gnu.org/cgit/screen.git

$(PKG)_BINARY:=$($(PKG)_DIR)/screen
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/screen.bin

$(PKG)_DEPENDS_ON += ncurses

$(PKG)_CONFIGURE_PRE_CMDS += $(AUTORECONF)

$(PKG)_CONFIGURE_OPTIONS += --disable-socket-dir
$(PKG)_CONFIGURE_OPTIONS += --with-sys-screenrc=/mod/etc/screenrc
$(PKG)_CONFIGURE_OPTIONS += --enable-colors256


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SCREEN_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(SCREEN_DIR) clean

$(pkg)-uninstall:
	$(RM) $(SCREEN_TARGET_BINARY)

$(PKG_FINISH)
