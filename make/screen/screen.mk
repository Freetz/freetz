$(call PKG_INIT_BIN, 4.0.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://ftp.uni-erlangen.de/pub/utilities/screen
$(PKG)_BINARY:=$($(PKG)_DIR)/screen
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/screen.bin

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
	PATH="$(TARGET_PATH)" $(MAKE) -C $(SCREEN_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	mkdir -p $(SCREEN_TARGET_DIR)/root/usr/share/terminfo/{a,d,l,r,s,v,x}
	cp $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/terminfo/a/ansi \
		$(SCREEN_TARGET_DIR)/root/usr/share/terminfo/a/
	cp $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/terminfo/d/dumb \
		$(SCREEN_TARGET_DIR)/root/usr/share/terminfo/d/
	cp $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/terminfo/l/linux \
		$(SCREEN_TARGET_DIR)/root/usr/share/terminfo/l/
	cp $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/terminfo/r/rxvt \
		$(SCREEN_TARGET_DIR)/root/usr/share/terminfo/r/
	cp $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/terminfo/s/{sun,screen-w,screen} \
		$(SCREEN_TARGET_DIR)/root/usr/share/terminfo/s/
	cp $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/terminfo/v/{vt52,vt100,vt102,vt200,vt220} \
		$(SCREEN_TARGET_DIR)/root/usr/share/terminfo/v/
	cp $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/terminfo/x/{xterm,xterm-color,xterm-xfree86} \
		$(SCREEN_TARGET_DIR)/root/usr/share/terminfo/x/
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(SCREEN_DIR) clean

$(pkg)-uninstall:
	$(RM) $(SCREEN_TARGET_BINARY)
	$(RM) $(SCREEN_TARGET_DIR)/root/usr/share/terminfo/{a,d,l,r,s,v,x}

$(PKG_FINISH)
