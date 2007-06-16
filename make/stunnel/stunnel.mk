# based on OpenWrt SVN
STUNNEL_VERSION:=4.20
STUNNEL_SOURCE:=stunnel-$(STUNNEL_VERSION).tar.gz
STUNNEL_SITE:=http://www.stunnel.org/download/stunnel/src
STUNNEL_MAKE_DIR:=$(MAKE_DIR)/stunnel
STUNNEL_DIR:=$(SOURCE_DIR)/stunnel-$(STUNNEL_VERSION)
STUNNEL_BINARY:=$(STUNNEL_DIR)/src/stunnel
STUNNEL_PKG_NAME:=stunnel-$(STUNNEL_VERSION)
STUNNEL_PKG_VERSION:=0.1b
STUNNEL_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages
STUNNEL_PKG_NAME:=stunnel-$(STUNNEL_VERSION)
STUNNEL_PKG_SOURCE:=stunnel-$(STUNNEL_VERSION)-dsmod-$(STUNNEL_PKG_VERSION).tar.bz2
STUNNEL_TARGET_DIR:=$(PACKAGES_DIR)/$(STUNNEL_PKG_NAME)
STUNNEL_TARGET_BINARY:=$(STUNNEL_TARGET_DIR)/root/usr/sbin/stunnel


$(DL_DIR)/$(STUNNEL_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(STUNNEL_SITE)/$(STUNNEL_SOURCE)

$(DL_DIR)/$(STUNNEL_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(STUNNEL_PKG_SOURCE) $(STUNNEL_PKG_SITE)

$(STUNNEL_DIR)/.unpacked: $(DL_DIR)/$(STUNNEL_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(STUNNEL_SOURCE)
	for i in $(STUNNEL_MAKE_DIR)/patches/*.patch; do \
		patch -d $(STUNNEL_DIR) -p0 < $$i; \
	done
	touch $@

$(STUNNEL_DIR)/.configured:  $(STUNNEL_DIR)/.unpacked
	( cd $(STUNNEL_DIR); rm -f config.{cache,status}; \
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
		--prefix= \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--datadir=/usr/share \
		--includedir=/usr/include \
		--libdir=/usr/lib \
		--libexecdir=/usr/lib \
		--localstatedir=/var \
		--sbindir=/usr/sbin \
		--sysconfdir=/mod/etc/stunnel \
		$(DISABLE_LARGEFILE) \
		$(DISABLE_NLS) \
		--disable-libwrap \
		--with-threads=fork \
		--with-ssl="$(TARGET_MAKE_PATH)/../usr" \
	);
	touch $@

$(STUNNEL_BINARY): $(STUNNEL_DIR)/.configured
	PATH="$(TARGET_PATH)" \
	$(MAKE) -C $(STUNNEL_DIR)

$(STUNNEL_TARGET_BINARY): $(STUNNEL_BINARY)
	$(INSTALL_BINARY_STRIP)

$(PACKAGES_DIR)/.$(STUNNEL_PKG_NAME): $(DL_DIR)/$(STUNNEL_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(STUNNEL_PKG_SOURCE)
	@touch $@

stunnel: $(PACKAGES_DIR)/.$(STUNNEL_PKG_NAME)

stunnel-package: $(PACKAGES_DIR)/.$(STUNNEL_PKG_NAME)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(STUNNEL_PKG_SOURCE) $(STUNNEL_PKG_NAME)

stunnel-precompiled: uclibc openssl-precompiled  stunnel $(STUNNEL_TARGET_BINARY)

stunnel-source: $(STUNNEL_DIR)/.unpacked $(PACKAGES_DIR)/.$(STUNNEL_PKG_NAME)

stunnel-clean:
	-$(MAKE) -C $(STUNNEL_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(STUNNEL_PKG_SOURCE)

stunnel-dirclean:
	rm -rf $(STUNNEL_DIR)
	rm -rf $(PACKAGES_DIR)/$(STUNNEL_PKG_NAME)
	rm -f $(PACKAGES_DIR)/.$(STUNNEL_PKG_NAME)

stunnel-uninstall:
	rm -f $(STUNNEL_TARGET_BINARY)

stunnel-list:
ifeq ($(strip $(DS_PACKAGE_STUNNEL)),y)
	@echo "S40stunnel-$(STUNNEL_VERSION)" >> .static
else
	@echo "S40stunnel-$(STUNNEL_VERSION)" >> .dynamic
endif
