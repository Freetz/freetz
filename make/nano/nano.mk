NANO_VERSION:=2.0.6
NANO_SOURCE:=nano-$(NANO_VERSION).tar.gz
NANO_SITE:=http://www.nano-editor.org/dist/v2.0
NANO_DIR:=$(SOURCE_DIR)/nano-$(NANO_VERSION)
NANO_MAKE_DIR:=$(MAKE_DIR)/nano
NANO_BINARY:=$(NANO_DIR)/src/nano
NANO_TARGET_DIR:=$(PACKAGES_DIR)/nano-$(NANO_VERSION)
NANO_TARGET_BINARY:=$(NANO_TARGET_DIR)/root/usr/bin/nano
NANO_PKG_VERSION:=0.3
NANO_PKG_SOURCE:=nano-$(NANO_VERSION)-dsmod-$(NANO_PKG_VERSION).tar.bz2
NANO_PKG_SITE:=http://mcknight.ath.cx/dsmod/packages

$(DL_DIR)/$(NANO_SOURCE):
	wget -P $(DL_DIR) $(NANO_SITE)/$(NANO_SOURCE)

$(DL_DIR)/$(NANO_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(NANO_PKG_SOURCE) $(NANO_PKG_SITE)

$(NANO_DIR)/.unpacked: $(DL_DIR)/$(NANO_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(NANO_SOURCE)
#	for i in $(NANO_MAKE_DIR)/patches/*.patch; do \
#		patch -d $(NANO_DIR) -p0 < $$i; \
#	done
	touch $@

$(NANO_DIR)/.configured: $(NANO_DIR)/.unpacked $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libncurses.so
	( cd $(NANO_DIR); rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include -I$(TARGET_MAKE_PATH)/../include" \
		LDFLAGS="-L$(TARGET_MAKE_PATH)/../lib -L$(TARGET_MAKE_PATH)/../usr/lib" \
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
			--disable-rpath \
			--enable-tiny \
			--disable-glibtest \
			--disable-utf8 \
			--without-slang \
	);
	touch $@

$(NANO_BINARY): $(NANO_DIR)/.configured
	PATH="$(TARGET_PATH)" make -C $(NANO_DIR)

$(NANO_TARGET_BINARY): $(NANO_BINARY) 
	mkdir -p $(NANO_TARGET_DIR)/root/usr/share/terminfo/{v,x}
	cp $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/terminfo/v/{vt102,vt102-nsgr,vt102-w} \
		$(NANO_TARGET_DIR)/root/usr/share/terminfo/v/
	cp $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/terminfo/x/xterm \
		$(NANO_TARGET_DIR)/root/usr/share/terminfo/x/
	$(INSTALL_BINARY_STRIP)

$(PACKAGES_DIR)/.nano-$(NANO_VERSION): $(DL_DIR)/$(NANO_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(NANO_PKG_SOURCE)
	@touch $@

nano: $(PACKAGES_DIR)/.nano-$(NANO_VERSION)

nano-package: $(PACKAGES_DIR)/.nano-$(NANO_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(NANO_PKG_SOURCE) nano-$(NANO_VERSION)

nano-precompiled: uclibc ncurses-precompiled nano $(NANO_TARGET_BINARY)

nano-source: $(NANO_DIR)/.unpacked $(PACKAGES_DIR)/.nano-$(NANO_VERSION)

nano-clean:
	-$(MAKE) -C $(NANO_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(NANO_PKG_SOURCE)

nano-dirclean:
	rm -rf $(NANO_DIR)
	rm -rf $(PACKAGES_DIR)/nano-$(NANO_VERSION)
	rm -f $(PACKAGES_DIR)/.nano-$(NANO_VERSION)

nano-uninstall: 
	rm -f $(NANO_TARGET_BINARY)

nano-list:
ifeq ($(strip $(DS_PACKAGE_NANO)),y)
	@echo "S99nano-$(NANO_VERSION)" >> .static
else
	@echo "S99nano-$(NANO_VERSION)" >> .dynamic
endif
