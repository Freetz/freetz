$(call PKG_INIT_BIN, 0.72)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=ftp://ftp.bitwizard.nl/mtr
$(PKG)_BINARY:=$($(PKG)_DIR)/mtr
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/mtr

$(PKG)_DEPENDS_ON := ncurses

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-static
$(PKG)_CONFIGURE_OPTIONS += --without-gtk
$(PKG)_CONFIGURE_OPTIONS += --disable-ipv6
$(PKG)_CONFIGURE_OPTIONS += --disable-gtktest


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(MTR_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY) 
	mkdir -p $(MTR_DEST_DIR)/usr/share/terminfo/x
	cp $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/terminfo/x/xterm \
		$(MTR_DEST_DIR)/usr/share/terminfo/x/
	$(INSTALL_BINARY_STRIP)

mtr:

mtr-precompiled: uclibc mtr $($(PKG)_TARGET_BINARY)

mtr-clean:
	-$(MAKE) -C $(MTR_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(MTR_PKG_SOURCE)

mtr-uninstall: 
	rm -f $(MTR_TARGET_BINARY)
	rm -rf $(MTR_DEST_DIR)/usr/share/terminfo/x

$(PKG_FINISH)