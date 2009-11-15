$(call PKG_INIT_BIN, 1.4.1.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://netfilter.org/projects/$(pkg)/files
$(PKG)_BINARY:=$($(PKG)_DIR)/iptables
$(PKG)_IP6_BINARY:=$($(PKG)_DIR)/ip6tables
$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/libiptc/libiptc.a
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/iptables
ifeq ($(FREETZ_TARGET_IPV6_SUPPORT),y)
$(PKG)_IP6_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/ip6tables
endif
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libiptc.a
$(PKG)_EXTENSIONS_DIR:=$(ROOT_DIR)/usr/lib/xtables
$(PKG)_TARGET_EXTENSIONS:=$($(PKG)_EXTENSIONS_DIR)/.installed
$(PKG)_CONFIGURE_ENV += AR="$(TARGET_MAKE_PATH)/$(TARGET_CROSS)ar" RANLIB="$(TARGET_MAKE_PATH)/$(TARGET_CROSS)ranlib"
$(PKG)_CONFIGURE_OPTIONS += --with-ksource="$(FREETZ_BASE_DIR)/$(KERNEL_SOURCE_DIR)"
$(PKG)_SOURCE_MD5:=723fa88d8a0915e184f99e03e9bf06cb

$(PKG_SOURCE_DOWNLOAD)

$(IPTABLES_DIR)/.unpacked: $(DL_DIR)/$(IPTABLES_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(IPTABLES_SOURCE)
	for i in $(IPTABLES_MAKE_DIR)/patches/*.patch; do \
		patch -d $(IPTABLES_DIR) -p0 < $$i; \
	done
ifneq ($(FREETZ_TARGET_IPV6_SUPPORT),y)
	patch -d $(IPTABLES_DIR) -p0 < $(IPTABLES_MAKE_DIR)/patches/cond/009-remove_ipv6.patch
endif
	touch $@

$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_IP6_BINARY) $($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured | kernel-source
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(IPTABLES_DIR)

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/
	cp $< $@

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_IP6_TARGET_BINARY): $($(PKG)_IP6_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_EXTENSIONS): $($(PKG)_BINARY)
	mkdir -p $(IPTABLES_EXTENSIONS_DIR)
	cp $(IPTABLES_DIR)/extensions/*.so $(IPTABLES_EXTENSIONS_DIR)/
	$(TARGET_STRIP) $(IPTABLES_EXTENSIONS_DIR)/*.so
	touch $@

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_IP6_TARGET_BINARY) $($(PKG)_TARGET_EXTENSIONS) $($(PKG)_LIB_STAGING_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(IPTABLES_DIR) clean
	$(RM) $(IPTABLES_LIB_STAGING_BINARY)

$(pkg)-uninstall:
	$(RM) $(IPTABLES_TARGET_BINARY)
	$(RM) $($(PKG)_IP6_TARGET_BINARY)
	$(RM) $(IPTABLES_EXTENSIONS_DIR)/*

$(PKG_FINISH)
