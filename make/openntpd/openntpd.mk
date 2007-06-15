OPENNTPD_VERSION:=3.9p1
OPENNTPD_SOURCE:=openntpd-$(OPENNTPD_VERSION).tar.gz
OPENNTPD_SITE:=ftp://ftp.openbsd.org/pub/OpenBSD/OpenNTPD/
OPENNTPD_MAKE_DIR:=$(MAKE_DIR)/openntpd
OPENNTPD_DIR:=$(SOURCE_DIR)/openntpd-$(OPENNTPD_VERSION)
OPENNTPD_BINARY:=$(OPENNTPD_DIR)/ntpd
OPENNTPD_PKG_VERSION:=0.2
OPENNTPD_PKG_SOURCE:=openntpd-$(OPENNTPD_VERSION)-dsmod-$(OPENNTPD_PKG_VERSION).tar.bz2
OPENNTPD_PKG_SITE:=http://mcknight.ath.cx/dsmod/packages
OPENNTPD_TARGET_DIR:=$(PACKAGES_DIR)/openntpd-$(OPENNTPD_VERSION)
OPENNTPD_TARGET_BINARY:=$(OPENNTPD_TARGET_DIR)/root/usr/sbin/ntpd

$(DL_DIR)/$(OPENNTPD_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(OPENNTPD_SITE)/$(OPENNTPD_SOURCE)

$(DL_DIR)/$(OPENNTPD_PKG_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(OPENNTPD_PKG_SOURCE) $(OPENNTPD_PKG_SITE)

$(OPENNTPD_DIR)/.unpacked: $(DL_DIR)/$(OPENNTPD_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(OPENNTPD_SOURCE)
	for i in $(OPENNTPD_MAKE_DIR)/patches/*.patch; do \
		patch -d $(OPENNTPD_DIR) -p1 < $$i; \
	done
	touch $@

$(OPENNTPD_DIR)/.configured: $(OPENNTPD_DIR)/.unpacked
	( cd $(OPENNTPD_DIR); rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC)" \
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
                  --sysconfdir=/etc \
                  $(DISABLE_LARGEFILE) \
                  $(DISABLE_NLS) \
                  --with-builtin-arc4random \
                  --with-privsep-user=ntp \
                  --with-adjtimex \
	);
	touch $@

$(OPENNTPD_BINARY): $(OPENNTPD_DIR)/.configured
	PATH="$(TARGET_PATH)" \
	$(MAKE) -C $(OPENNTPD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) -DUSE_ADJTIMEX" \
		LDFLAGS=""

$(OPENNTPD_TARGET_BINARY): $(OPENNTPD_BINARY)
	$(INSTALL_BINARY_STRIP)

$(PACKAGES_DIR)/.openntpd-$(OPENNTPD_VERSION): $(DL_DIR)/$(OPENNTPD_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(OPENNTPD_PKG_SOURCE)
	@touch $@

openntpd: $(PACKAGES_DIR)/.openntpd-$(OPENNTPD_VERSION)

openntpd-package: $(PACKAGES_DIR)/.openntpd-$(OPENNTPD_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(OPENNTPD_PKG_SOURCE) openntpd-$(OPENNTPD_VERSION)

openntpd-precompiled: uclibc openntpd $(OPENNTPD_TARGET_BINARY) 

openntpd-source: $(OPENNTPD_DIR)/.unpacked $(PACKAGES_DIR)/.openntpd-$(OPENNTPD_VERSION)

openntpd-clean:
	-$(MAKE) -C $(OPENNTPD_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(OPENNTPD_PKG_SOURCE)

openntpd-dirclean:
	rm -rf $(OPENNTPD_DIR)
	rm -rf $(PACKAGES_DIR)/openntpd-$(OPENNTPD_VERSION)
	rm -f $(PACKAGES_DIR)/.openntpd-$(OPENNTPD_VERSION)

openntpd-uninstall: 
	rm -f $(OPENNTPD_TARGET_BINARY)

openntpd-list:
ifeq ($(strip $(DS_PACKAGE_OPENNTPD)),y)
	@echo "S40openntpd-$(OPENNTPD_VERSION)" >> .static
else
	@echo "S40openntpd-$(OPENNTPD_VERSION)" >> .dynamic
endif
