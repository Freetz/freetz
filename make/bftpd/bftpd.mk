BFTPD_VERSION:=1.8
BFTPD_SOURCE:=bftpd-$(BFTPD_VERSION).tar.gz
BFTPD_SITE:=http://mesh.dl.sourceforge.net/sourceforge/bftpd
BFTPD_DIR:=$(SOURCE_DIR)/bftpd-$(BFTPD_VERSION)
BFTPD_MAKE_DIR:=$(MAKE_DIR)/bftpd
BFTPD_TARGET_BINARY:=bftpd
BFTPD_PKG_VERSION:=0.5
#BFTPD_PKG_SITE:=http://www.eiband.info/dsmod
BFTPD_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages
ifeq ($(strip $(DS_PACKAGE_BFTPD_WITH_ZLIB)),y)
BFTPD_PKG_NAME:=bftpd-zlib-$(BFTPD_VERSION)
BFTPD_PKG_SOURCE:=bftpd-$(BFTPD_VERSION)-dsmod-$(BFTPD_PKG_VERSION)-with-zlib.tar.bz2
BFTPD_ZLIB:=--enable-libz
BFTPD_LIBZLIB:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libz.so
else
BFTPD_PKG_NAME:=bftpd-$(BFTPD_VERSION)
BFTPD_PKG_SOURCE:=bftpd-$(BFTPD_VERSION)-dsmod-$(BFTPD_PKG_VERSION).tar.bz2
BFTPD_ZLIB:=
BFTPD_LIBZLIB:=
endif
BFTPD_TARGET_DIR:=$(PACKAGES_DIR)/$(BFTPD_PKG_NAME)/root/usr/sbin


$(DL_DIR)/$(BFTPD_SOURCE):
	wget -P $(DL_DIR) $(BFTPD_SITE)/$(BFTPD_SOURCE)

$(DL_DIR)/$(BFTPD_PKG_SOURCE):
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(BFTPD_PKG_SOURCE) $(BFTPD_PKG_SITE)

$(BFTPD_DIR)/.unpacked: $(DL_DIR)/$(BFTPD_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(BFTPD_SOURCE)
	for i in $(BFTPD_MAKE_DIR)/patches/*.patch; do \
		patch -d $(BFTPD_DIR) -p0 < $$i; \
	done
	touch $@

$(BFTPD_DIR)/.configured: $(BFTPD_DIR)/.unpacked $(BFTPD_LIBZLIB)
	( cd $(BFTPD_DIR); rm -f config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-L$(TARGET_MAKE_PATH)/../usr/lib -static-libgcc" \
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
		$(DISABLE_NLS) \
		$(DISABLE_LARGEFILE) \
		$(BFTPD_ZLIB) \
	);
	touch $@

$(BFTPD_DIR)/$(BFTPD_TARGET_BINARY): $(BFTPD_DIR)/.configured
	PATH="$(TARGET_PATH)" \
	$(MAKE) CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-L$(TARGET_MAKE_PATH)/../lib -L$(TARGET_MAKE_PATH)/../usr/lib -static-libgcc" \
		-C $(BFTPD_DIR) 

$(PACKAGES_DIR)/.$(BFTPD_PKG_NAME): $(DL_DIR)/$(BFTPD_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(BFTPD_PKG_SOURCE)
	@touch $@

bftpd: $(PACKAGES_DIR)/.$(BFTPD_PKG_NAME)

bftpd-package: $(PACKAGES_DIR)/.$(BFTPD_PKG_NAME)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(BFTPD_PKG_SOURCE) $(BFTPD_PKG_NAME) 

bftpd-precompiled: $(BFTPD_DIR)/$(BFTPD_TARGET_BINARY) bftpd
	$(TARGET_STRIP) $(BFTPD_DIR)/$(BFTPD_TARGET_BINARY)
	cp $(BFTPD_DIR)/$(BFTPD_TARGET_BINARY) $(BFTPD_TARGET_DIR)/

bftpd-source: $(BFTPD_DIR)/.unpacked $(PACKAGES_DIR)/.$(BFTPD_PKG_NAME)

bftpd-clean:
	-$(MAKE) -C $(BFTPD_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(BFTPD_PKG_SOURCE)

bftpd-dirclean:
	rm -rf $(BFTPD_DIR)
	rm -rf $(PACKAGES_DIR)/$(BFTPD_PKG_NAME)
	rm -f $(PACKAGES_DIR)/.$(BFTPD_PKG_NAME)

bftpd-list:
ifeq ($(strip $(DS_PACKAGE_BFTPD_WITH_ZLIB)),y)
ifeq ($(strip $(DS_PACKAGE_BFTPD)),y)
	@echo "S40bftpd-zlib-$(BFTPD_VERSION)" >> .static
else
	@echo "S40bftpd-zlib-$(BFTPD_VERSION)" >> .dynamic
endif
else
ifeq ($(strip $(DS_PACKAGE_BFTPD)),y)
	@echo "S40bftpd-$(BFTPD_VERSION)" >> .static
else
	@echo "S40bftpd-$(BFTPD_VERSION)" >> .dynamic
endif
endif
