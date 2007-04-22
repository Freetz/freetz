MATRIXTUNNEL_VERSION:=0.2
MATRIXTUNNEL_SOURCE:=matrixtunnel-$(MATRIXTUNNEL_VERSION).tar.gz
MATRIXTUNNEL_SITE:=http://znerol.ch/files
MATRIXTUNNEL_DIR:=$(SOURCE_DIR)/matrixtunnel
MATRIXTUNNEL_MAKE_DIR:=$(MAKE_DIR)/matrixtunnel
MATRIXTUNNEL_TARGET_DIR:=$(PACKAGES_DIR)/matrixtunnel-$(MATRIXTUNNEL_VERSION)/root/usr/sbin
MATRIXTUNNEL_TARGET_BINARY:=matrixtunnel
MATRIXTUNNEL_PKG_VERSION:=0.1
MATRIXTUNNEL_PKG_SOURCE:=matrixtunnel-$(MATRIXTUNNEL_VERSION)-dsmod-$(MATRIXTUNNEL_PKG_VERSION).tar.bz2
MATRIXTUNNEL_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages
MATRIXTUNNEL_PKG_SOURCE:=matrixtunnel-$(MATRIXTUNNEL_VERSION)-dsmod-binary-only.tar.bz2


$(DL_DIR)/$(MATRIXTUNNEL_SOURCE):
	wget -P $(DL_DIR) $(MATRIXTUNNEL_SITE)/$(MATRIXTUNNEL_SOURCE)

$(DL_DIR)/$(MATRIXTUNNEL_PKG_SOURCE):
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(MATRIXTUNNEL_PKG_SOURCE) $(MATRIXTUNNEL_PKG_SITE)

$(MATRIXTUNNEL_DIR)/.unpacked: $(DL_DIR)/$(MATRIXTUNNEL_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(MATRIXTUNNEL_SOURCE)
#	for i in $(MATRIXTUNNEL_MAKE_DIR)/patches/*.patch; do \
#		patch -d $(MATRIXTUNNEL_DIR) -p1 < $$i; \
#	done
	touch $@

$(MATRIXTUNNEL_DIR)/.configured: $(MATRIXTUNNEL_DIR)/.unpacked \
				 $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmatrixssl.so
	( cd $(MATRIXTUNNEL_DIR); rm -f config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-static-libgcc -L$(TARGET_MAKE_PATH)/../usr/lib -lpthread" \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--program-prefix="" \
		--program-suffix="" \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/usr/sbin \
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
		--without-libiconv-prefix \
		--without-libintl-prefix \
		--with-matrixssl-src="$(shell pwd)/$(MATRIXSSL_DIR)" \
	);
	touch $@

$(MATRIXTUNNEL_DIR)/$(MATRIXTUNNEL_TARGET_BINARY): $(MATRIXTUNNEL_DIR)/.configured
	( PATH="$(TARGET_PATH)" \
		make -C $(MATRIXTUNNEL_DIR)/src all \
	);

$(PACKAGES_DIR)/.matrixtunnel-$(MATRIXTUNNEL_VERSION): $(DL_DIR)/$(MATRIXTUNNEL_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(MATRIXTUNNEL_PKG_SOURCE)
	@touch $@

matrixtunnel: $(PACKAGES_DIR)/.matrixtunnel-$(MATRIXTUNNEL_VERSION)

matrixtunnel-package: $(PACKAGES_DIR)/.matrixtunnel-$(MATRIXTUNNEL_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(MATRIXTUNNEL_PKG_SOURCE) matrixtunnel-$(MATRIXTUNNEL_VERSION)

matrixtunnel-precompiled: $(MATRIXTUNNEL_DIR)/$(MATRIXTUNNEL_TARGET_BINARY) matrixtunnel
	$(TARGET_STRIP) $(MATRIXTUNNEL_DIR)/src/$(MATRIXTUNNEL_TARGET_BINARY)
	cp $(MATRIXTUNNEL_DIR)/src/$(MATRIXTUNNEL_TARGET_BINARY) $(MATRIXTUNNEL_TARGET_DIR)/

matrixtunnel-source: $(MATRIXTUNNEL_DIR)/.unpacked $(PACKAGES_DIR)/.matrixtunnel-$(MATRIXTUNNEL_VERSION)

matrixtunnel-clean:
	-$(MAKE) -C $(MATRIXTUNNEL_DIR)/src clean
	rm -f $(PACKAGES_BUILD_DIR)/$(MATRIXTUNNEL_PKG_SOURCE)

matrixtunnel-dirclean:
	rm -rf $(MATRIXTUNNEL_DIR)
	rm -rf $(PACKAGES_DIR)/matrixtunnel-$(MATRIXTUNNEL_VERSION)
	rm -f $(PACKAGES_DIR)/.matrixtunnel-$(MATRIXTUNNEL_VERSION)

matrixtunnel-list:
ifeq ($(strip $(DS_PACKAGE_MATRIXTUNNEL)),y)
	@echo "S40matrixtunnel-$(MATRIXTUNNEL_VERSION)" >> .static
else
	@echo "S40matrixtunnel-$(MATRIXTUNNEL_VERSION)" >> .dynamic
endif
