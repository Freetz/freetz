$(call PKG_INIT_BIN, 2.51)
$(PKG)_SOURCE:=dnsmasq-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://thekelleys.org.uk/dnsmasq
$(PKG)_DIR:=$(SOURCE_DIR)/dnsmasq-$($(PKG)_VERSION)
$(PKG)_BINARY:=$(DNSMASQ_DIR)/src/dnsmasq
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/root/usr/sbin/dnsmasq
$(PKG)_STARTLEVEL=40
$(PKG)_SOURCE_MD5:=97465261a6de5258a3c3edfe51ca16a4

ifneq ($(FREETZ_TARGET_IPV6_SUPPORT),y) 
$(PKG)_COPTS := -DNO_IPV6
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(DNSMASQ_DIR) \
		CC="$(TARGET_CC)" \
		COPTS="$(DNSMASQ_COPTS)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS=""

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(DNSMASQ_DIR) clean

$(pkg)-uninstall:
	$(RM) $(DNSMASQ_TARGET_BINARY)

$(PKG_FINISH)
