NETCAT_NAME:=netcat
NETCAT_VERSION:=0.7.1
NETCAT_SOURCE:=$(NETCAT_NAME)-$(NETCAT_VERSION).tar.gz
NETCAT_SITE:=http://mesh.dl.sourceforge.net/sourceforge/netcat
NETCAT_DIR:=$(SOURCE_DIR)/$(NETCAT_NAME)-$(NETCAT_VERSION)
NETCAT_MAKE_DIR:=$(MAKE_DIR)/$(NETCAT_NAME)
NETCAT_BINARY:=$(NETCAT_DIR)/src/netcat
NETCAT_TARGET_DIR:=$(PACKAGES_DIR)/$(NETCAT_NAME)-$(NETCAT_VERSION)
NETCAT_TARGET_BINARY:=$(NETCAT_TARGET_DIR)/root/usr/bin/netcat
NETCAT_PKG_VERSION:=0.1
NETCAT_PKG_SOURCE:=$(NETCAT_NAME)-$(NETCAT_VERSION)-dsmod-$(NETCAT_PKG_VERSION).tar.bz2
NETCAT_PKG_SITE:=http://mcknight.ath.cx/dsmod/packages

$(DL_DIR)/$(NETCAT_SOURCE):
	wget -P $(DL_DIR) $(NETCAT_SITE)/$(NETCAT_SOURCE)

$(DL_DIR)/$(NETCAT_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(NETCAT_PKG_SOURCE) $(NETCAT_PKG_SITE)

$(NETCAT_DIR)/.unpacked: $(DL_DIR)/$(NETCAT_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(NETCAT_SOURCE)
#	for i in $(NETCAT_MAKE_DIR)/patches/*.patch; do \
#		patch -d $(NETCAT_DIR) -p0 < $$i; \
#	done
	touch $@

$(NETCAT_DIR)/.configured: $(NETCAT_DIR)/.unpacked
	( cd $(NETCAT_DIR); rm -f config.{cache,status}; \
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
			--with-included-getopt \
	);
	touch $@

$(NETCAT_BINARY): $(NETCAT_DIR)/.configured
	PATH="$(TARGET_PATH)" make -C $(NETCAT_DIR)

$(NETCAT_TARGET_BINARY): $(NETCAT_BINARY) 
	$(INSTALL_BINARY_STRIP)

$(PACKAGES_DIR)/.$(NETCAT_NAME)-$(NETCAT_VERSION): $(DL_DIR)/$(NETCAT_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(NETCAT_PKG_SOURCE)
	@touch $@

netcat: $(PACKAGES_DIR)/.$(NETCAT_NAME)-$(NETCAT_VERSION)

netcat-download: $(DL_DIR)/$(NETCAT_SOURCE) $(DL_DIR)/$(NETCAT_PKG_SOURCE)

netcat-package: $(PACKAGES_DIR)/.$(NETCAT_NAME)-$(NETCAT_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(NETCAT_PKG_SOURCE) $(NETCAT_NAME)-$(NETCAT_VERSION)

netcat-precompiled: uclibc netcat $(NETCAT_TARGET_BINARY)

netcat-source: $(NETCAT_DIR)/.unpacked $(PACKAGES_DIR)/.$(NETCAT_NAME)-$(NETCAT_VERSION)

netcat-clean:
	-$(MAKE) -C $(NETCAT_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(NETCAT_PKG_SOURCE)

netcat-dirclean:
	rm -rf $(NETCAT_DIR)
	rm -rf $(PACKAGES_DIR)/$(NETCAT_NAME)-$(NETCAT_VERSION)
	rm -f $(PACKAGES_DIR)/.$(NETCAT_NAME)-$(NETCAT_VERSION)

netcat-uninstall: 
	rm -f $(NETCAT_TARGET_BINARY)

netcat-list:
ifeq ($(strip $(DS_PACKAGE_NETCAT)),y)
	@echo "S99$(NETCAT_NAME)-$(NETCAT_VERSION)" >> .static
else
	@echo "S99$(NETCAT_NAME)-$(NETCAT_VERSION)" >> .dynamic
endif
