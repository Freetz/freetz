# based on OpenWrt SVN
OPENVPN_VERSION:=2.1_rc2
OPENVPN_SOURCE:=openvpn-$(OPENVPN_VERSION).tar.gz
OPENVPN_SITE:=http://openvpn.net/release
OPENVPN_DIR:=$(SOURCE_DIR)/openvpn-$(OPENVPN_VERSION)
OPENVPN_TARGET_BINARY:=openvpn
OPENVPN_PKG_VERSION:=0.6b
OPENVPN_PKG_SITE:=http://netfreaks.org/ds-mod
ifeq ($(strip $(DS_PACKAGE_OPENVPN_WITH_LZO)),y)
OPENVPN_PKG_NAME:=openvpn-lzo-$(OPENVPN_VERSION)
OPENVPN_PKG_SOURCE:=openvpn-$(OPENVPN_VERSION)-dsmod-$(OPENVPN_PKG_VERSION)-lzo.tar.bz2
DISABLE_LZO:=
else
OPENVPN_PKG_NAME:=openvpn-$(OPENVPN_VERSION)
OPENVPN_PKG_SOURCE:=openvpn-$(OPENVPN_VERSION)-dsmod-$(OPENVPN_PKG_VERSION).tar.bz2
DISABLE_LZO:=--disable-lzo
endif
OPENVPN_TARGET_DIR:=$(PACKAGES_DIR)/$(OPENVPN_PKG_NAME)/root/usr/sbin


$(DL_DIR)/$(OPENVPN_SOURCE):
	wget -P $(DL_DIR) $(OPENVPN_SITE)/$(OPENVPN_SOURCE)

$(DL_DIR)/$(OPENVPN_PKG_SOURCE):
	@wget -P $(DL_DIR) $(OPENVPN_PKG_SITE)/$(OPENVPN_PKG_SOURCE)

$(OPENVPN_DIR)/.unpacked: $(DL_DIR)/$(OPENVPN_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(OPENVPN_SOURCE)
	touch $@

$(OPENVPN_DIR)/.configured: openssl lzo $(OPENVPN_DIR)/.unpacked
	( cd $(OPENVPN_DIR); rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-static-libgcc -L$(TARGET_MAKE_PATH)/../usr/lib" \
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
		--sysconfdir=/mod/etc/openvpn \
		$(DISABLE_LARGEFILE) \
		$(DISABLE_NLS) \
		$(DISABLE_LZO) \
		--enable-shared \
		--disable-static \
		--disable-pthread \
		--disable-debug \
		--disable-plugins \
		--disable-management \
		--disable-socks \
		--disable-http \
		--enable-password-save \
		--enable-small \
	);
	touch $@

$(OPENVPN_DIR)/$(OPENVPN_TARGET_BINARY): $(OPENVPN_DIR)/.configured
	PATH="$(TARGET_PATH)" \
	$(MAKE) -C $(OPENVPN_DIR)

$(PACKAGES_DIR)/.$(OPENVPN_PKG_NAME): $(DL_DIR)/$(OPENVPN_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(OPENVPN_PKG_SOURCE)
	@touch $@

openvpn: $(PACKAGES_DIR)/.$(OPENVPN_PKG_NAME)

openvpn-package: $(PACKAGES_DIR)/.$(OPENVPN_PKG_NAME)
	tar -C $(PACKAGES_DIR) $(VERBOSE) -cjf $(PACKAGES_BUILD_DIR)/$(OPENVPN_PKG_SOURCE) $(OPENVPN_PKG_NAME)

openvpn-precompiled: $(OPENVPN_DIR)/$(OPENVPN_TARGET_BINARY) openvpn
	$(TARGET_STRIP) $(OPENVPN_DIR)/$(OPENVPN_TARGET_BINARY)
	cp $(OPENVPN_DIR)/$(OPENVPN_TARGET_BINARY) $(OPENVPN_TARGET_DIR)/

openvpn-source: $(OPENVPN_DIR)/.unpacked $(PACKAGES_DIR)/.$(OPENVPN_PKG_NAME)

openvpn-clean:
	-$(MAKE) -C $(OPENVPN_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(OPENVPN_PKG_SOURCE)

openvpn-dirclean:
	rm -rf $(OPENVPN_DIR)
	rm -rf $(PACKAGES_DIR)/$(OPENVPN_PKG_NAME)
	rm -f $(PACKAGES_DIR)/.$(OPENVPN_PKG_NAME)

openvpn-list:
ifeq ($(strip $(DS_PACKAGE_OPENVPN_WITH_LZO)),y)
ifeq ($(strip $(DS_PACKAGE_OPENVPN)),y)
	@echo "S40openvpn-lzo-$(OPENVPN_VERSION)" >> .static
else
	@echo "S40openvpn-lzo-$(OPENVPN_VERSION)" >> .dynamic
endif
else
ifeq ($(strip $(DS_PACKAGE_OPENVPN)),y)
	@echo "S40openvpn-$(OPENVPN_VERSION)" >> .static
else
	@echo "S40openvpn-$(OPENVPN_VERSION)" >> .dynamic
endif
endif
