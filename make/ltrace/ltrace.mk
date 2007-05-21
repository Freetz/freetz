LTRACE_VERSION:=0.4
LTRACE_SOURCE:=ltrace_$(LTRACE_VERSION).orig.tar.gz
LTRACE_SITE:=http://ftp.debian.org/debian/pool/main/l/ltrace
LTRACE_DIR:=$(SOURCE_DIR)/ltrace-$(LTRACE_VERSION)
LTRACE_MAKE_DIR:=$(MAKE_DIR)/ltrace
LTRACE_TARGET_DIR:=$(PACKAGES_DIR)/ltrace-$(LTRACE_VERSION)/root/usr/sbin
LTRACE_TARGET_BINARY:=ltrace
LTRACE_PKG_SOURCE:=ltrace-$(LTRACE_VERSION)-dsmod.tar.bz2
LTRACE_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages

$(DL_DIR)/$(LTRACE_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(LTRACE_SITE)/$(LTRACE_SOURCE)

$(DL_DIR)/$(LTRACE_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(LTRACE_PKG_SOURCE) $(LTRACE_PKG_SITE)

$(LTRACE_DIR)/.unpacked: $(DL_DIR)/$(LTRACE_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(LTRACE_SOURCE)
#	for i in $(LTRACE_MAKE_DIR)/patches/*.patch; do \
#		patch -d $(LTRACE_DIR) -p0 < $$i; \
#	done
	touch $@

$(LTRACE_DIR)/.configured: $(LTRACE_DIR)/.unpacked
	( cd $(LTRACE_DIR); rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
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
		--sysconfdir=/etc \
		$(DISABLE_NLS) \
		$(DISABLE_LARGEFILE) \
	);
	touch $@

$(LTRACE_DIR)/$(LTRACE_TARGET_BINARY): $(LTRACE_DIR)/.configured
	PATH="$(TARGET_PATH)" $(MAKE) -C $(LTRACE_DIR) ARCH=mips
	
$(PACKAGES_DIR)/.ltrace-$(LTRACE_VERSION): $(DL_DIR)/$(LTRACE_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(LTRACE_PKG_SOURCE)
	@touch $@

ltrace: $(PACKAGES_DIR)/.ltrace-$(LTRACE_VERSION)

ltrace-package: $(PACKAGES_DIR)/.ltrace-$(LTRACE_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(LTRACE_PKG_SOURCE) ltrace-$(LTRACE_VERSION)


ltrace-precompiled: uclibc libelf-precompiled $(LTRACE_DIR)/$(LTRACE_TARGET_BINARY) ltrace
	$(TARGET_STRIP) $(LTRACE_DIR)/$(LTRACE_TARGET_BINARY)
	cp $(LTRACE_DIR)/$(LTRACE_TARGET_BINARY) $(LTRACE_TARGET_DIR)/

ltrace-source: $(LTRACE_DIR)/.unpacked $(PACKAGES_DIR)/.ltrace-$(LTRACE_VERSION)

ltrace-clean:
	-$(MAKE) -C $(LTRACE_DIR) clean ARCH=mips
	rm -f $(PACKAGES_BUILD_DIR)/$(LTRACE_PKG_SOURCE)

ltrace-dirclean:
	rm -rf $(LTRACE_DIR)
	rm -rf $(PACKAGES_DIR)/ltrace-$(LTRACE_VERSION)
	rm -f $(PACKAGES_DIR)/.ltrace-$(LTRACE_VERSION)

ltrace-list:
ifeq ($(strip $(DS_PACKAGE_LTRACE)),y)
	@echo "S40ltrace-$(LTRACE_VERSION)" >> .static
else
	@echo "S40ltrace-$(LTRACE_VERSION)" >> .dynamic
endif
