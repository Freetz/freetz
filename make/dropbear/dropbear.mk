# based on OpenWrt SVN
DROPBEAR_VERSION:=0.49
DROPBEAR_SOURCE:=dropbear-$(DROPBEAR_VERSION).tar.gz
DROPBEAR_SITE:=http://matt.ucc.asn.au/dropbear/releases
DROPBEAR_MAKE_DIR:=$(MAKE_DIR)/dropbear
DROPBEAR_DIR:=$(SOURCE_DIR)/dropbear-$(DROPBEAR_VERSION)
DROPBEAR_BINARY:=$(DROPBEAR_DIR)/dropbearmulti
DROPBEAR_PKG_VERSION:=0.6
DROPBEAR_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages
ifeq ($(strip $(DS_PACKAGE_DROPBEAR_SERVER_ONLY)),y)
DROPBEAR_PKG_NAME:=dropbear-sshd-$(DROPBEAR_VERSION)
DROPBEAR_PKG_SOURCE:=dropbear-$(DROPBEAR_VERSION)-dsmod-$(DROPBEAR_PKG_VERSION)-sshd-only.tar.bz2
else
DROPBEAR_PKG_NAME:=dropbear-$(DROPBEAR_VERSION)
DROPBEAR_PKG_SOURCE:=dropbear-$(DROPBEAR_VERSION)-dsmod-$(DROPBEAR_PKG_VERSION).tar.bz2
endif
DROPBEAR_TARGET_DIR:=$(PACKAGES_DIR)/$(DROPBEAR_PKG_NAME)
DROPBEAR_TARGET_BINARY:=$(DROPBEAR_TARGET_DIR)/root/usr/sbin/dropbearmulti


$(DL_DIR)/$(DROPBEAR_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(DROPBEAR_SITE)/$(DROPBEAR_SOURCE)

$(DL_DIR)/$(DROPBEAR_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(DROPBEAR_PKG_SOURCE) $(DROPBEAR_PKG_SITE)

$(DROPBEAR_DIR)/.unpacked: $(DL_DIR)/$(DROPBEAR_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(DROPBEAR_SOURCE)
	for i in $(DROPBEAR_MAKE_DIR)/patches/*.patch; do \
		patch -d $(DROPBEAR_DIR) -p0 < $$i; \
	done
	touch $@

$(DROPBEAR_DIR)/.configured: $(DROPBEAR_DIR)/.unpacked
	( cd $(DROPBEAR_DIR); rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="-static-libgcc" \
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
		--disable-pam \
		--enable-openpty \
		--enable-syslog \
		--enable-shadow \
		--disable-lastlog \
		--disable-utmp \
		--disable-utmpx \
		--disable-wtmp \
		--disable-wtmpx \
		--disable-loginfunc \
		--disable-pututline \
		--disable-pututxline \
		--disable-zlib \
	);
	touch $@

$(DROPBEAR_BINARY): $(DROPBEAR_DIR)/.configured
ifeq ($(strip $(DS_PACKAGE_DROPBEAR_SERVER_ONLY)),y)
	PATH="$(TARGET_PATH)" $(MAKE) PROGRAMS="dropbear dropbearkey" MULTI=1 \
		-C $(DROPBEAR_DIR)
else
	PATH="$(TARGET_PATH)" $(MAKE) PROGRAMS="dropbear dbclient dropbearkey scp" MULTI=1 SCPPROGRESS=1 \
		-C $(DROPBEAR_DIR)
endif

$(DROPBEAR_TARGET_BINARY): $(DROPBEAR_BINARY)
	$(TARGET_STRIP) $(DROPBEAR_BINARY)
	cp $(DROPBEAR_BINARY) $(DROPBEAR_TARGET_BINARY)

$(PACKAGES_DIR)/.$(DROPBEAR_PKG_NAME): $(DL_DIR)/$(DROPBEAR_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(DROPBEAR_PKG_SOURCE)
	@touch $@

dropbear: $(PACKAGES_DIR)/.$(DROPBEAR_PKG_NAME)

dropbear-package: $(PACKAGES_DIR)/.$(DROPBEAR_PKG_NAME)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(DROPBEAR_PKG_SOURCE) $(DROPBEAR_PKG_NAME)

dropbear-precompiled: uclibc dropbear $(DROPBEAR_TARGET_BINARY)

dropbear-source: $(DROPBEAR_DIR)/.unpacked $(PACKAGES_DIR)/.$(DROPBEAR_PKG_NAME)

dropbear-clean:
	-$(MAKE) -C $(DROPBEAR_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(DROPBEAR_PKG_SOURCE)

dropbear-dirclean:
	rm -rf $(DROPBEAR_DIR)
	rm -rf $(PACKAGES_DIR)/$(DROPBEAR_PKG_NAME)
	rm -f $(PACKAGES_DIR)/.$(DROPBEAR_PKG_NAME)

dropbear-uninstall:
	rm -f $(DROPBEAR_TARGET_BINARY)

dropbear-list:
ifeq ($(strip $(DS_PACKAGE_DROPBEAR_SERVER_ONLY)),y)
ifeq ($(strip $(DS_PACKAGE_DROPBEAR)),y)
	@echo "S40dropbear-sshd-$(DROPBEAR_VERSION)" >> .static
else
	@echo "S40dropbear-sshd-$(DROPBEAR_VERSION)" >> .dynamic
endif
else
ifeq ($(strip $(DS_PACKAGE_DROPBEAR)),y)
	@echo "S40dropbear-$(DROPBEAR_VERSION)" >> .static
else
	@echo "S40dropbear-$(DROPBEAR_VERSION)" >> .dynamic
endif
endif
