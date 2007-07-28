MTR_NAME:=mtr
MTR_VERSION:=0.69
MTR_SOURCE:=$(MTR_NAME)-$(MTR_VERSION).tar.gz
MTR_SITE:=ftp://ftp.bitwizard.nl/mtr
MTR_DIR:=$(SOURCE_DIR)/$(MTR_NAME)-$(MTR_VERSION)
MTR_MAKE_DIR:=$(MAKE_DIR)/$(MTR_NAME)
MTR_BINARY:=$(MTR_DIR)/mtr
MTR_TARGET_DIR:=$(PACKAGES_DIR)/$(MTR_NAME)-$(MTR_VERSION)
MTR_TARGET_BINARY:=$(MTR_TARGET_DIR)/root/usr/sbin/mtr
MTR_PKG_VERSION:=0.1
MTR_PKG_SOURCE:=$(MTR_NAME)-$(MTR_VERSION)-dsmod-$(MTR_PKG_VERSION).tar.bz2
MTR_PKG_SITE:=http://www.mhampicke.de/dsmod/packages

$(DL_DIR)/$(MTR_SOURCE):
	wget -P $(DL_DIR) $(MTR_SITE)/$(MTR_SOURCE)

$(DL_DIR)/$(MTR_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(MTR_PKG_SOURCE) $(MTR_PKG_SITE)

$(MTR_DIR)/.unpacked: $(DL_DIR)/$(MTR_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(MTR_SOURCE)
	for i in $(MTR_MAKE_DIR)/patches/*.patch; do \
		$(PATCH_TOOL) $(MTR_DIR) $$i 1; \
	done
	touch $@

$(MTR_DIR)/.configured: $(MTR_DIR)/.unpacked $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libncurses.so
	( cd $(MTR_DIR); rm -f config.{cache,status}; \
		touch configure.in aclocal.m4 Makefile.in img/Makefile.in stamp-h.in config.h.in configure ; \
		$(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include -I$(TARGET_MAKE_PATH)/../include" \
		LDFLAGS="-L$(TARGET_MAKE_PATH)/../lib -L$(TARGET_MAKE_PATH)/../usr/lib" \
		ac_cv_lib_resolv_res_mkquery=yes \
		./configure \
			--target=$(GNU_TARGET_NAME) \
			--host=$(GNU_TARGET_NAME) \
			--build=$(GNU_HOST_NAME) \
			--program-prefix="" \
			--program-suffix="" \
			--prefix=/usr \
			--exec-prefix=/usr \
			--bindir=/usr/bin \
			--datadir=/usr/share \
			--includedir=/usr/include \
			--infodir=/usr/share/info \
			--libdir=/usr/lib \
			--libexecdir=/usr/lib \
			--localstatedir=/var \
			--mandir=/usr/share/man \
			--sbindir=/usr/sbin \
			--sysconfdir=/etc \
			$(DISABLE_LARGEFILE) \
			$(DISABLE_NLS) \
			--enable-shared \
			--disable-static \
			--with-gnu-ld \
			--without-gtk \
			--disable-ipv6 \
			--disable-gtktest \
	);
	touch $@

$(MTR_BINARY): $(MTR_DIR)/.configured
	PATH="$(TARGET_PATH)" make -C $(MTR_DIR)

$(MTR_TARGET_BINARY): $(MTR_BINARY) 
	mkdir -p $(MTR_TARGET_DIR)/root/usr/share/terminfo/x
	cp $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/terminfo/x/xterm \
		$(MTR_TARGET_DIR)/root/usr/share/terminfo/x/

	$(INSTALL_BINARY_STRIP)

$(PACKAGES_DIR)/.$(MTR_NAME)-$(MTR_VERSION): $(DL_DIR)/$(MTR_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(MTR_PKG_SOURCE)
	@touch $@

mtr: $(PACKAGES_DIR)/.$(MTR_NAME)-$(MTR_VERSION)

mtr-download: $(DL_DIR)/$(MTR_SOURCE) $(DL_DIR)/$(MTR_PKG_SOURCE)

mtr-package: $(PACKAGES_DIR)/.$(MTR_NAME)-$(MTR_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(MTR_PKG_SOURCE) $(MTR_NAME)-$(MTR_VERSION)

mtr-precompiled: uclibc ncurses-precompiled mtr $(MTR_TARGET_BINARY)

mtr-source: $(MTR_DIR)/.unpacked $(PACKAGES_DIR)/.$(MTR_NAME)-$(MTR_VERSION)

mtr-clean:
	-$(MAKE) -C $(MTR_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(MTR_PKG_SOURCE)

mtr-dirclean:
	rm -rf $(MTR_DIR)
	rm -rf $(PACKAGES_DIR)/$(MTR_NAME)-$(MTR_VERSION)
	rm -f $(PACKAGES_DIR)/.$(MTR_NAME)-$(MTR_VERSION)

mtr-uninstall: 
	rm -f $(MTR_TARGET_BINARY)

mtr-list:
ifeq ($(strip $(DS_PACKAGE_MTR)),y)
	@echo "S99$(MTR_NAME)-$(MTR_VERSION)" >> .static
else
	@echo "S99$(MTR_NAME)-$(MTR_VERSION)" >> .dynamic
endif
