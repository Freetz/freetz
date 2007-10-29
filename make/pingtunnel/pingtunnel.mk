PACKAGE_LC:=pingtunnel
PACKAGE_UC:=PINGTUNNEL
$(PACKAGE_UC)_VERSION:=0.61
$(PACKAGE_INIT_BIN)
$(PACKAGE_UC)_SOURCE:=PingTunnel-$($(PACKAGE_UC)_VERSION).tar.gz
$(PACKAGE_UC)_SITE:=http://www.cs.uit.no/~daniels/PingTunnel/
$(PACKAGE_UC)_DIR:=$(SOURCE_DIR)/PingTunnel
$(PACKAGE_UC)_BINARY:=$($(PACKAGE_UC)_DIR)/ptunnel
$(PACKAGE_UC)_PKG_VERSION:=
$(PACKAGE_UC)_TARGET_BINARY:=$($(PACKAGE_UC)_DEST_DIR)/usr/sbin/ptunnel

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)
$(PACKAGE_CONFIGURED_NOP)

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(PINGTUNNEL_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -DVERSION='\"$(PINGTUNNEL_VERSION)\"'" \
		LDOPTS="-lpthread -lpcap"

$($(PACKAGE_UC)_TARGET_BINARY): $($(PACKAGE_UC)_BINARY)
	$(INSTALL_BINARY_STRIP)

pingtunnel:

pingtunnel-precompiled: uclibc libpcap-precompiled pingtunnel $($(PACKAGE_UC)_TARGET_BINARY) 

pingtunnel-clean:
	-$(MAKE) -C $(PINGTUNNEL_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(PINGTUNNEL_PKG_SOURCE)

pingtunnel-uninstall:
	rm -f $(PINGTUNNEL_TARGET_BINARY)
	
$(PACKAGE_FINI)
