PACKAGE_LC:=mtr
PACKAGE_UC:=MTR
MTR_NAME:=mtr
MTR_VERSION:=0.72
MTR_SOURCE:=$(MTR_NAME)-$(MTR_VERSION).tar.gz
MTR_SITE:=ftp://ftp.bitwizard.nl/mtr
MTR_DIR:=$(SOURCE_DIR)/$(MTR_NAME)-$(MTR_VERSION)
MTR_MAKE_DIR:=$(MAKE_DIR)/$(MTR_NAME)
MTR_BINARY:=$(MTR_DIR)/mtr
MTR_TARGET_DIR:=$(PACKAGES_DIR)/$(MTR_NAME)-$(MTR_VERSION)
MTR_TARGET_BINARY:=$(MTR_TARGET_DIR)/root/usr/sbin/mtr
MTR_PKG_VERSION:=0.1
MTR_STARTLEVEL=99

$(PACKAGE_UC)_CONFIGURE_PRE_CMDS += touch configure.in aclocal.m4 Makefile.in img/Makefile.in stamp-h.in config.h.in configure ;
$(PACKAGE_UC)_CONFIGURE_ENV += ac_cv_lib_resolv_res_mkquery=yes
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-shared
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-static
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --with-gnu-ld
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --without-gtk
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-ipv6
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-gtktest


$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_BIN_UNPACKED)
$(PACKAGE_CONFIGURED_CONFIGURE)

$(MTR_BINARY): $(MTR_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(MTR_DIR)

$(MTR_TARGET_BINARY): $(MTR_BINARY) 
	mkdir -p $(MTR_TARGET_DIR)/root/usr/share/terminfo/x
	cp $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/terminfo/x/xterm \
		$(MTR_TARGET_DIR)/root/usr/share/terminfo/x/
	mkdir -p $(dir $(MTR_TARGET_BINARY))
	$(INSTALL_BINARY_STRIP)

mtr:

mtr-download: $(DL_DIR)/$(MTR_SOURCE) $(DL_DIR)/$(MTR_PKG_SOURCE)

mtr-precompiled: uclibc ncurses-precompiled mtr $(MTR_TARGET_BINARY)

mtr-source: $(MTR_DIR)/.unpacked

mtr-clean:
	-$(MAKE) -C $(MTR_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(MTR_PKG_SOURCE)

mtr-dirclean:
	rm -rf $(MTR_DIR)
	rm -rf $(PACKAGES_DIR)/$(MTR_NAME)-$(MTR_VERSION)

mtr-uninstall: 
	rm -f $(MTR_TARGET_BINARY)
	rm -rf $(MTR_TARGET_DIR)/root/usr/share/terminfo/x

$(PACKAGE_LIST)