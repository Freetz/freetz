DECO_VERSION:=39
DECO_SOURCE:=deco$(DECO_VERSION).tgz
DECO_SITE:=http://mesh.dl.sourceforge.net/sourceforge/deco
DECO_MAKE_DIR:=$(MAKE_DIR)/deco
DECO_DIR:=$(SOURCE_DIR)/deco$(DECO_VERSION)
DECO_BINARY:=$(DECO_DIR)/deco
DECO_TARGET_DIR:=$(PACKAGES_DIR)/deco-$(DECO_VERSION)
DECO_TARGET_BINARY:=$(DECO_TARGET_DIR)/root/usr/bin/deco
DECO_PKG_VERSION:=0.1
DECO_PKG_SOURCE:=deco-$(DECO_VERSION)-dsmod-$(DECO_PKG_VERSION).tar.bz2
DECO_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages

$(DL_DIR)/$(DECO_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(DECO_SITE)/$(DECO_SOURCE)

$(DL_DIR)/$(DECO_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(DECO_PKG_SOURCE) $(DECO_PKG_SITE)

$(DECO_DIR)/.unpacked: $(DL_DIR)/$(DECO_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(DECO_SOURCE)
	for i in $(DECO_MAKE_DIR)/patches/*.patch; do \
		$(PATCH_TOOL) $(DECO_DIR) $$i; \
	done
	touch $@

$(DECO_DIR)/.configured: $(DECO_DIR)/.unpacked
	( cd $(DECO_DIR); rm -f config.cache; \
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
	);
	touch $@

$(DECO_BINARY): $(DECO_DIR)/.configured
	PATH="$(TARGET_PATH)" $(MAKE) -C $(DECO_DIR)

$(DECO_TARGET_BINARY): $(DECO_BINARY)
	$(INSTALL_BINARY_STRIP)
	@# Don't copy these, because they are already part of the package:
	@#cp $(DECO_DIR)/profile $(DECO_TARGET_DIR)/root/usr/lib/deco/profile
	@#cp $(DECO_DIR)/menu $(DECO_TARGET_DIR)/root/usr/lib/deco/menu

$(PACKAGES_DIR)/.deco-$(DECO_VERSION): $(DL_DIR)/$(DECO_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(DECO_PKG_SOURCE)
	@touch $@

deco: $(PACKAGES_DIR)/.deco-$(DECO_VERSION)

deco-package: $(PACKAGES_DIR)/.deco-$(DECO_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(DECO_PKG_SOURCE) deco-$(DECO_VERSION)

deco-precompiled: uclibc ncurses-precompiled deco $(DECO_TARGET_BINARY)

deco-source: $(DECO_DIR)/.unpacked $(PACKAGES_DIR)/.deco-$(DECO_VERSION)

deco-clean:
	-$(MAKE) -C $(DECO_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(DECO_PKG_SOURCE)

deco-dirclean:
	rm -rf $(DECO_DIR)
	rm -rf $(PACKAGES_DIR)/deco-$(DECO_VERSION)
	rm -f $(PACKAGES_DIR)/.deco-$(DECO_VERSION)

deco-uninstall:
	rm -f $(DECO_TARGET_BINARY)

deco-list:
ifeq ($(strip $(DS_PACKAGE_DECO)),y)
	@echo "S99deco-$(DECO_VERSION)" >> .static
else
	@echo "S99deco-$(DECO_VERSION)" >> .dynamic
endif
