JAMVM_VERSION:=1.4.5
JAMVM_UGLY_VERSION:=0.0.0
JAMVM_SOURCE:=jamvm-$(JAMVM_VERSION).tar.gz
JAMVM_SITE:=http://mesh.dl.sourceforge.net/sourceforge/jamvm
JAMVM_MAKE_DIR:=$(MAKE_DIR)/jamvm
JAMVM_DIR:=$(SOURCE_DIR)/jamvm-$(JAMVM_VERSION)
JAMVM_BINARY:=$(JAMVM_DIR)/src/jamvm
JAMVM_LIB_BINARY:=$(JAMVM_DIR)/src/.libs/libjvm.so.$(JAMVM_UGLY_VERSION)
JAMVM_TARGET_DIR:=$(PACKAGES_DIR)/jamvm-$(JAMVM_VERSION)
JAMVM_TARGET_BINARY:=$(JAMVM_TARGET_DIR)/root/usr/bin/jamvm
JAMVM_TARGET_LIB_BINARY:=$(JAMVM_TARGET_DIR)/root/usr/lib/libjvm.so.$(JAMVM_UGLY_VERSION)
JAMVM_PKG_VERSION:=0.1
JAMVM_PKG_SOURCE:=jamvm-$(JAMVM_VERSION)-dsmod-$(JAMVM_PKG_VERSION).tar.bz2
JAMVM_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages
JAMVM_PKG_SOURCE:=jamvm-$(JAMVM_VERSION)-dsmod-binary-only.tar.bz2

$(DL_DIR)/$(JAMVM_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(JAMVM_SITE)/$(JAMVM_SOURCE)

$(DL_DIR)/$(JAMVM_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(JAMVM_PKG_SOURCE) $(JAMVM_PKG_SITE)

$(JAMVM_DIR)/.unpacked: $(DL_DIR)/$(JAMVM_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(JAMVM_SOURCE)
	for i in $(JAMVM_MAKE_DIR)/patches/*.patch; do \
		patch -d $(JAMVM_DIR) -p0 < $$i; \
	done
	touch $@

$(JAMVM_DIR)/.configured: $(JAMVM_DIR)/.unpacked
	( cd $(JAMVM_DIR); rm -f config.status; \
		$(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-L$(TARGET_MAKE_PATH)/../usr/lib" \
		./configure \
		--target="$(GNU_TARGET_NAME)" \
		--host="$(GNU_TARGET_NAME)" \
		--build="$(GNU_HOST_NAME)" \
		--enable-ffi \
		--disable-int-threading \
		--with-classpath-install-dir="/usr/share/classpath" \
	);
	touch $@
	

$(JAMVM_BINARY) $(JAMVM_LIB_BINARY): $(JAMVM_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(JAMVM_DIR)/src

$(JAMVM_TARGET_BINARY): $(JAMVM_BINARY)
	$(INSTALL_BINARY_STRIP)

$(JAMVM_TARGET_LIB_BINARY): $(JAMVM_LIB_BINARY)
	cp -a $(JAMVM_DIR)/src/.libs/libjvm*.so* $(JAMVM_TARGET_DIR)/root/usr/lib
	$(TARGET_STRIP) $@

$(PACKAGES_DIR)/.jamvm-$(JAMVM_VERSION): $(DL_DIR)/$(JAMVM_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(JAMVM_PKG_SOURCE)
	@touch $@

jamvm: $(PACKAGES_DIR)/.jamvm-$(JAMVM_VERSION)

jamvm-package: $(PACKAGES_DIR)/.jamvm-$(JAMVM_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(JAMVM_PKG_SOURCE) jamvm-$(JAMVM_VERSION)

jamvm-precompiled: uclibc ffi-sable-precompiled classpath-precompiled jamvm \
		$(JAMVM_TARGET_BINARY) $(JAMVM_TARGET_LIB_BINARY)

jamvm-source: $(JAMVM_DIR)/.unpacked $(PACKAGES_DIR)/.jamvm-$(JAMVM_VERSION)

jamvm-clean:
	-$(MAKE) -C $(JAMVM_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(JAMVM_PKG_SOURCE)

jamvm-dirclean:
	rm -rf $(JAMVM_DIR)
	rm -rf $(PACKAGES_DIR)/jamvm-$(JAMVM_VERSION)
	rm -f $(PACKAGES_DIR)/.jamvm-$(JAMVM_VERSION)

jamvm-uninstall:
	rm -f $(JAMVM_TARGET_BINARY)
	rm -f $(JAMVM_TARGET_DIR)/root/usr/lib/libjvm*.so*

jamvm-list:
ifeq ($(strip $(DS_PACKAGE_JAMVM)),y)
	@echo "S40jamvm-$(JAMVM_VERSION)" >> .static
else
	@echo "S40jamvm-$(JAMVM_VERSION)" >> .dynamic
endif
