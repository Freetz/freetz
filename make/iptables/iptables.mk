# take care of patches/150-iptables.sh
$(call PKG_INIT_BIN, 1.4.1.1)
#$(PKG)_VERSION:=1.4.1.1
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://netfilter.org/projects/$(pkg)/files
$(PKG)_BINARY:=$($(PKG)_DIR)/iptables
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/iptables
$(PKG)_EXTENSIONS_DIR:=$($(PKG)_DEST_DIR)/usr/lib/xtables
$(PKG)_TARGET_EXTENSIONS:=$($(PKG)_EXTENSIONS_DIR)/.installed
$(PKG)_CONFIGURE_ENV += AR="$(TARGET_MAKE_PATH)/$(TARGET_CROSS)ar" RANLIB="$(TARGET_MAKE_PATH)/$(TARGET_CROSS)ranlib"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured | kernel-source
	find "$(IPTABLES_DIR)" -name "*ip6*" -o -name "*ipv6*" | xargs rm -rf
	$(MAKE) -C $(IPTABLES_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_EXTENSIONS): $($(PKG)_BINARY)
	mkdir -p $(IPTABLES_EXTENSIONS_DIR)
	cp $(IPTABLES_DIR)/extensions/*.so $(IPTABLES_EXTENSIONS_DIR)/
	$(TARGET_STRIP) $(IPTABLES_EXTENSIONS_DIR)/*.so
	touch $@

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_EXTENSIONS)

$(pkg)-clean:
	-$(MAKE) -C $(IPTABLES_DIR) clean

$(pkg)-uninstall:
	rm -f $(IPTABLES_TARGET_BINARY)
	rm -f $(IPTABLES_EXTENSIONS_DIR)/*

$(PKG_FINISH)
