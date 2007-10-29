PACKAGE_LC:=mtr
PACKAGE_UC:=MTR
$(PACKAGE_UC)_VERSION:=0.72
$(PACKAGE_INIT_BIN)
$(PACKAGE_UC)_SOURCE:=$(PACKAGE_UC)-$($(PACKAGE_UC)_VERSION).tar.gz
$(PACKAGE_UC)_SITE:=ftp://ftp.bitwizard.nl/mtr
$(PACKAGE_UC)_BINARY:=$($(PACKAGE_UC)_DIR)/mtr
$(PACKAGE_UC)_TARGET_BINARY:=$($(PACKAGE_UC)_DEST_DIR)/usr/sbin/mtr


$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-shared
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-static
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --without-gtk
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-ipv6
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-gtktest


$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)
$(PACKAGE_CONFIGURED_CONFIGURE)

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(MTR_DIR)

$($(PACKAGE_UC)_TARGET_BINARY): $($(PACKAGE_UC)_BINARY) 
	mkdir -p $(MTR_DEST_DIR)/usr/share/terminfo/x
	cp $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/terminfo/x/xterm \
		$(MTR_DEST_DIR)/usr/share/terminfo/x/
	$(INSTALL_BINARY_STRIP)

mtr:

mtr-precompiled: uclibc ncurses-precompiled mtr $($(PACKAGE_UC)_TARGET_BINARY)

mtr-clean:
	-$(MAKE) -C $(MTR_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(MTR_PKG_SOURCE)

mtr-uninstall: 
	rm -f $(MTR_TARGET_BINARY)
	rm -rf $(MTR_DEST_DIR)/usr/share/terminfo/x

$(PACKAGE_FINI)