# take care of patches/150-iptables.sh
$(call PKG_INIT_BIN, 1.3.7)
$(PKG)_VERSION:=1.3.7
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://netfilter.org/projects/$(pkg)/files
$(PKG)_BINARY:=$($(PKG)_DIR)/iptables
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/iptables
$(PKG)_EXTENSIONS_DIR:=$($(PKG)_DEST_DIR)/usr/lib/iptables
$(PKG)_TARGET_EXTENSIONS:=$($(PKG)_EXTENSIONS_DIR)/.installed
$(PKG)_KERNEL_DIR:=$(FREETZ_BASE_DIR)/$(KERNEL_SOURCE_DIR)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): \
		$($(PKG)_DIR)/.configured | kernel-source
	chmod +x $(IPTABLES_DIR)/extensions/.*-test*
	$(MAKE) KERNEL_DIR="$(IPTABLES_KERNEL_DIR)" \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
		COPT_FLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="-rdynamic" \
		PREFIX=/usr \
		DO_IPV6=0 \
		-C $(IPTABLES_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_EXTENSIONS): $($(PKG)_BINARY)
	mkdir -p $(IPTABLES_EXTENSIONS_DIR)
	cp $(IPTABLES_DIR)/extensions/*.so $(IPTABLES_EXTENSIONS_DIR)/
	$(TARGET_STRIP) $(IPTABLES_EXTENSIONS_DIR)/*.so
	touch $@

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_EXTENSIONS)

$(pkg)-clean:
	-$(MAKE) KERNEL_DIR="$(IPTABLES_KERNEL_DIR)" \
		CC="$(TARGET_CC)" \
		-C $(IPTABLES_DIR) clean

$(pkg)-uninstall:
	rm -f $(IPTABLES_TARGET_BINARY)
	rm -f $(IPTABLES_EXTENSIONS_DIR)/*

$(PKG_FINISH)