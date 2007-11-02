# based on OpenWrt SVN
OPENVPN_VERSION:=2.1_rc4
OPENVPN_SOURCE:=openvpn-$(OPENVPN_VERSION).tar.gz
OPENVPN_SITE:=http://openvpn.net/release
OPENVPN_MAKE_DIR:=$(MAKE_DIR)/openvpn
OPENVPN_DIR:=$(SOURCE_DIR)/openvpn-$(OPENVPN_VERSION)
OPENVPN_BINARY:=$(OPENVPN_DIR)/openvpn
OPENVPN_PKG_VERSION:=0.7
OPENVPN_PKG_SITE:=http://netfreaks.org/ds-mod

ifeq ($(strip $(DS_PACKAGE_OPENVPN_WITH_LZO)),y)
OPENVPN_LZO:=lzo-precompiled 
else
OPENVPN_LZO:=
endif

OPENVPN_PKG_NAME:=openvpn-$(OPENVPN_VERSION)
OPENVPN_PKG_SOURCE:=openvpn-$(OPENVPN_VERSION)-dsmod-$(OPENVPN_PKG_VERSION).tar.bz2
OPENVPN_TARGET_DIR:=$(PACKAGES_DIR)/$(OPENVPN_PKG_NAME)
OPENVPN_TARGET_BINARY:=$(OPENVPN_TARGET_DIR)/root/usr/sbin/openvpn

OPENVPN_DS_CONFIG_FILE:=$(OPENVPN_MAKE_DIR)/.ds_config
OPENVPN_DS_CONFIG_TEMP:=$(OPENVPN_MAKE_DIR)/.ds_config.temp

$(DL_DIR)/$(OPENVPN_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(OPENVPN_SITE)/$(OPENVPN_SOURCE)

$(DL_DIR)/$(OPENVPN_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(OPENVPN_PKG_SOURCE) $(OPENVPN_PKG_SITE)

$(OPENVPN_DS_CONFIG_FILE): $(TOPDIR)/.config
	@echo "DS_PACKAGE_OPENVPN_WITH_LZO=$(if $(DS_PACKAGE_OPENVPN_WITH_LZO),y,n)" > $(OPENVPN_DS_CONFIG_TEMP)
	@echo "DS_PACKAGE_OPENVPN_WITH_MGMNT=$(if $(DS_PACKAGE_OPENVPN_WITH_MGMNT),y,n)" >> $(OPENVPN_DS_CONFIG_TEMP)
	@echo "DS_PACKAGE_OPENVPN_ENABLE_SMALL=$(if $(DS_PACKAGE_OPENVPN_ENABLE_SMALL),y,n)" >> $(OPENVPN_DS_CONFIG_TEMP)
	@diff -q $(OPENVPN_DS_CONFIG_TEMP) $(OPENVPN_DS_CONFIG_FILE) || \
		cp $(OPENVPN_DS_CONFIG_TEMP) $(OPENVPN_DS_CONFIG_FILE)
	@rm -f $(OPENVPN_DS_CONFIG_TEMP)

# Make sure that a perfectly clean build is performed whenever DS-Mod package
# options have changed. The safest way to achieve this is by starting over
# with the source directory.
$(OPENVPN_DIR)/.unpacked: $(DL_DIR)/$(OPENVPN_SOURCE) $(OPENVPN_DS_CONFIG_FILE)
	rm -rf $(OPENVPN_DIR)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(OPENVPN_SOURCE)
	touch $@

$(OPENVPN_DIR)/.configured: $(OPENVPN_DIR)/.unpacked
	( cd $(OPENVPN_DIR); rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-L$(TARGET_MAKE_PATH)/../usr/lib" \
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
		$(if $(DS_PACKAGE_OPENVPN_WITH_LZO),,--disable-lzo) \
		--enable-shared \
		--disable-static \
		--disable-pthread \
		--disable-debug \
		--disable-plugins \
		$(if $(DS_PACKAGE_OPENVPN_WITH_MGMNT),--enable-management,--disable-management) \
		--disable-socks \
		--disable-http \
		--enable-password-save \
		$(if $(DS_PACKAGE_OPENVPN_ENABLE_SMALL),--enable-small,--disable-small) \
	);
	touch $@

$(OPENVPN_BINARY): $(OPENVPN_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(OPENVPN_DIR)

$(OPENVPN_TARGET_BINARY): $(OPENVPN_BINARY)
	$(INSTALL_BINARY_STRIP)

$(PACKAGES_DIR)/.$(OPENVPN_PKG_NAME): $(DL_DIR)/$(OPENVPN_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(OPENVPN_PKG_SOURCE)
	@touch $@

openvpn: $(PACKAGES_DIR)/.$(OPENVPN_PKG_NAME)

openvpn-package: #$(PACKAGES_DIR)/.$(OPENVPN_PKG_NAME)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(OPENVPN_PKG_SOURCE) $(OPENVPN_PKG_NAME)

openvpn-precompiled: uclibc $(OPENVPN_LZO) openssl-precompiled openvpn $(OPENVPN_TARGET_BINARY)

openvpn-source: $(OPENVPN_DIR)/.unpacked $(PACKAGES_DIR)/.$(OPENVPN_PKG_NAME)

openvpn-clean:
	-$(MAKE) -C $(OPENVPN_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(OPENVPN_PKG_SOURCE)
	rm -f $(OPENVPN_DS_CONFIG_FILE)

openvpn-dirclean:
	rm -rf $(OPENVPN_DIR)
	rm -rf $(PACKAGES_DIR)/$(OPENVPN_PKG_NAME)
	rm -f $(PACKAGES_DIR)/.$(OPENVPN_PKG_NAME)
	rm -f $(OPENVPN_DS_CONFIG_FILE)

openvpn-uninstall:
	rm -f $(OPENVPN_TARGET_BINARY)

openvpn-list:
ifeq ($(strip $(DS_PACKAGE_OPENVPN)),y)
	@echo "S40openvpn-$(OPENVPN_VERSION)" >> .static
else
	@echo "S40openvpn-$(OPENVPN_VERSION)" >> .dynamic
endif
