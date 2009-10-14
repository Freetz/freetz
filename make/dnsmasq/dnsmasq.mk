$(call PKG_INIT_BIN, 2.50)
$(PKG)_SOURCE:=dnsmasq-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://thekelleys.org.uk/dnsmasq
$(PKG)_DIR:=$(SOURCE_DIR)/dnsmasq-$($(PKG)_VERSION)
$(PKG)_BINARY:=$(DNSMASQ_DIR)/src/dnsmasq
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/root/usr/sbin/dnsmasq
$(PKG)_STARTLEVEL=40
$(PKG)_SOURCE_MD5:=f7b1e17c590e493039537434c57c9de7 


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(MAKE) CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="" \
		-C $(DNSMASQ_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(DNSMASQ_DIR) clean

$(pkg)-uninstall:
	$(RM) $(DNSMASQ_TARGET_BINARY)

$(PKG_FINISH)
