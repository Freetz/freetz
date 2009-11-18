$(call PKG_INIT_BIN, 4.0.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://ftp.uni-erlangen.de/pub/utilities/screen
$(PKG)_BINARY:=$($(PKG)_DIR)/screen
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/screen.bin
$(PKG)_SOURCE_MD5:=8506fd205028a96c741e4037de6e3c42

$(PKG)_DEPENDS_ON := ncurses

$(PKG)_CONFIGURE_ENV += $(foreach flag,rename fchmod fchown strerror lstat _exit utimes vsnprintf getcwd setlocale strftime,ac_cv_func_$(flag)=yes )

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-socket-dir
$(PKG)_CONFIGURE_OPTIONS += --with-sys-screenrc=/mod/etc/screenrc

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
