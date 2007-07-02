MC_VERSION:=4.5.0
MC_SOURCE:=mc-$(MC_VERSION).tar.gz
MC_SITE:=http://www.ibiblio.org/pub/Linux/utils/file/managers/mc/old
MC_MAKE_DIR:=$(MAKE_DIR)/mc
MC_DIR:=$(SOURCE_DIR)/mc-$(MC_VERSION)
MC_BINARY:=$(MC_DIR)/src/mc
MC_PKG_VERSION:=0.4
MC_PKG_SOURCE:=mc-$(MC_VERSION)-dsmod-$(MC_PKG_VERSION).tar.bz2
MC_PKG_SITE:=http://dsmod.magenbrot.net
MC_TARGET_DIR:=$(PACKAGES_DIR)/mc-$(MC_VERSION)
MC_TARGET_BINARY:=$(MC_TARGET_DIR)/root/usr/bin/mc.bin

$(DL_DIR)/$(MC_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(MC_SITE)/$(MC_SOURCE)

$(DL_DIR)/$(MC_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(MC_PKG_SOURCE) $(MC_PKG_SITE)

$(MC_DIR)/.unpacked: $(DL_DIR)/$(MC_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(MC_SOURCE)
	for i in $(MC_MAKE_DIR)/patches/*.patch; do \
		patch -d $(MC_DIR) -p0 < $$i; \
	done
	touch $@

$(MC_DIR)/.configured: $(MC_DIR)/.unpacked
	( cd $(MC_DIR); rm -f config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="" \
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
		--without-x \
		--without-subshell \
		--with-terminfo \
	);
	touch $@

$(MC_BINARY): $(MC_DIR)/.configured
	PATH="$(TARGET_PATH)" $(MAKE) -C $(MC_DIR)
	
$(MC_TARGET_BINARY): $(MC_BINARY) 
	mkdir -p $(MC_TARGET_DIR)/root/usr/share/terminfo/x
	cp $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/terminfo/x/xterm \
		$(MC_TARGET_DIR)/root/usr/share/terminfo/x/
	$(INSTALL_BINARY_STRIP)

$(PACKAGES_DIR)/.mc-$(MC_VERSION): $(DL_DIR)/$(MC_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(MC_PKG_SOURCE)
	@touch $@

mc: $(PACKAGES_DIR)/.mc-$(MC_VERSION)

mc-package: $(PACKAGES_DIR)/.mc-$(MC_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(MC_PKG_SOURCE) mc-$(MC_VERSION)

mc-precompiled: uclibc ncurses mc $(MC_TARGET_BINARY) 

mc-source: $(MC_DIR)/.unpacked $(PACKAGES_DIR)/.mc-$(MC_VERSION)

mc-clean:
	-$(MAKE) -C $(MC_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(MC_PKG_SOURCE)

mc-dirclean:
	rm -rf $(MC_DIR)
	rm -rf $(PACKAGES_DIR)/mc-$(MC_VERSION)
	rm -f $(PACKAGES_DIR)/.mc-$(MC_VERSION)

mc-uninstall: 
	rm -f $(MC_TARGET_BINARY)
	rm -rf $(MC_TARGET_DIR)/root/usr/share/terminfo/x

mc-list:
ifeq ($(strip $(DS_PACKAGE_MC)),y)
	@echo "S99mc-$(MC_VERSION)" >> .static
else
	@echo "S99mc-$(MC_VERSION)" >> .dynamic
endif
