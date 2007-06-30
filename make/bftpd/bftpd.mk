BFTPD_VERSION:=1.8
BFTPD_SOURCE:=bftpd-$(BFTPD_VERSION).tar.gz
BFTPD_SITE:=http://mesh.dl.sourceforge.net/sourceforge/bftpd
BFTPD_MAKE_DIR:=$(MAKE_DIR)/bftpd
BFTPD_DIR:=$(SOURCE_DIR)/bftpd-$(BFTPD_VERSION)
BFTPD_BINARY:=$(BFTPD_DIR)/bftpd
BFTPD_PKG_VERSION:=0.5
BFTPD_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages
ifeq ($(strip $(DS_PACKAGE_BFTPD_WITH_ZLIB)),y)
BFTPD_PKG_NAME:=bftpd-zlib-$(BFTPD_VERSION)
BFTPD_PKG_SOURCE:=bftpd-$(BFTPD_VERSION)-dsmod-$(BFTPD_PKG_VERSION)-with-zlib.tar.bz2
BFTPD_LIBS:=zlib-precompiled
else
BFTPD_PKG_NAME:=bftpd-$(BFTPD_VERSION)
BFTPD_PKG_SOURCE:=bftpd-$(BFTPD_VERSION)-dsmod-$(BFTPD_PKG_VERSION).tar.bz2
endif
BFTPD_TARGET_DIR:=$(PACKAGES_DIR)/$(BFTPD_PKG_NAME)
BFTPD_TARGET_BINARY:=$(BFTPD_TARGET_DIR)/root/usr/sbin/bftpd

BFTPD_DS_CONFIG_FILE:=$(BFTPD_MAKE_DIR)/.ds_config
BFTPD_DS_CONFIG_TEMP:=$(BFTPD_MAKE_DIR)/.ds_config.temp

$(DL_DIR)/$(BFTPD_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(BFTPD_SITE)/$(BFTPD_SOURCE)

$(DL_DIR)/$(BFTPD_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(BFTPD_PKG_SOURCE) $(BFTPD_PKG_SITE)

$(BFTPD_DS_CONFIG_FILE): $(TOPDIR)/.config
	@echo "DS_PACKAGE_BFTPD_WITH_ZLIB=$(if $(DS_PACKAGE_BFTPD_WITH_ZLIB),y,n)" > $(BFTPD_DS_CONFIG_TEMP)
	@diff -q $(BFTPD_DS_CONFIG_TEMP) $(BFTPD_DS_CONFIG_FILE) || \
		cp $(BFTPD_DS_CONFIG_TEMP) $(BFTPD_DS_CONFIG_FILE)
	@rm -f $(BFTPD_DS_CONFIG_TEMP)

# Make sure that a perfectly clean build is performed whenever DS-Mod package
# options have changed. The safest way to achieve this is by starting over
# with the source directory.
$(BFTPD_DIR)/.unpacked: $(DL_DIR)/$(BFTPD_SOURCE) $(BFTPD_DS_CONFIG_FILE)
	rm -rf $(BFTPD_DIR)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(BFTPD_SOURCE)
	for i in $(BFTPD_MAKE_DIR)/patches/*.patch; do \
		patch -d $(BFTPD_DIR) -p0 < $$i; \
	done
	touch $@

$(BFTPD_DIR)/.configured: $(BFTPD_DIR)/.unpacked
	( cd $(BFTPD_DIR); rm -f config.cache; \
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
		$(DISABLE_NLS) \
		$(DISABLE_LARGEFILE) \
		$(if $(DS_PACKAGE_BFTPD_WITH_ZLIB),--enable-libz) \
	);
	touch $@

$(BFTPD_BINARY): $(BFTPD_DIR)/.configured
	PATH="$(TARGET_PATH)" \
	$(MAKE) CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-L$(TARGET_MAKE_PATH)/../lib -L$(TARGET_MAKE_PATH)/../usr/lib" \
		-C $(BFTPD_DIR)

$(PACKAGES_DIR)/.$(BFTPD_PKG_NAME): $(DL_DIR)/$(BFTPD_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(BFTPD_PKG_SOURCE)
	@touch $@

$(BFTPD_TARGET_BINARY): $(BFTPD_BINARY)
	$(INSTALL_BINARY_STRIP)

bftpd: $(PACKAGES_DIR)/.$(BFTPD_PKG_NAME)

bftpd-package: $(PACKAGES_DIR)/.$(BFTPD_PKG_NAME)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(BFTPD_PKG_SOURCE) $(BFTPD_PKG_NAME) 

bftpd-precompiled: uclibc $(BFTPD_LIBS) bftpd $(BFTPD_TARGET_BINARY)

bftpd-source: $(BFTPD_DIR)/.unpacked $(PACKAGES_DIR)/.$(BFTPD_PKG_NAME)

bftpd-clean:
	-$(MAKE) -C $(BFTPD_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(BFTPD_PKG_SOURCE)
	rm -f $(BFTPD_DS_CONFIG_FILE)

bftpd-dirclean:
	rm -rf $(BFTPD_DIR)
	rm -rf $(PACKAGES_DIR)/$(BFTPD_PKG_NAME)
	rm -f $(PACKAGES_DIR)/.$(BFTPD_PKG_NAME)
	rm -f $(BFTPD_DS_CONFIG_FILE)

bftpd-uninstall:
	rm -f $(BFTPD_TARGET_BINARY)

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
