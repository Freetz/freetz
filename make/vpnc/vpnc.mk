$(call PKG_INIT_BIN, 0.5.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.unix-ag.uni-kl.de/~massar/vpnc
$(PKG)_BINARY:=$($(PKG)_DIR)/vpnc
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/sbin/vpnc
$(PKG)_STARTLEVEL=40
$(PKG)_SOURCE_MD5:=4378f9551d5b077e1770bbe09995afb3

$(PKG)_DEPENDS_ON := libgpg-error libgcrypt

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_VPNC_WITH_HYBRID_AUTH
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_VPNC_NAT_SUPPORT

ifeq ($(strip $(FREETZ_PACKAGE_VPNC_WITH_HYBRID_AUTH)),y)
$(PKG)_DEPENDS_ON += openssl
$(PKG)_CPPFLAGS := -DOPENSSL_GPL_VIOLATION
$(PKG)_LDFLAGS := -lcrypto
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(VPNC_DIR) vpnc \
		CC="$(TARGET_CC)" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include $(VPNC_CPPFLAGS)" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" \
		EXTRA_LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib $(VPNC_LDFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(PKG)_NAT_SUPPORT: $(PACKAGES_DIR)/.$(pkg)-$($(PKG)_VERSION)
ifeq ($(strip $(FREETZ_PACKAGE_VPNC_NAT_SUPPORT)),y)
	@$(SED) -i -e 's/#start_vpn_nat/start_vpn_nat/g' $(VPNC_DEST_DIR)/etc/default.vpnc/vpnc-script
	@$(SED) -i -e 's/#stop_vpn_nat/stop_vpn_nat/g' $(VPNC_DEST_DIR)/etc/default.vpnc/vpnc-script
endif

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $(PKG)_NAT_SUPPORT

$(pkg)-clean:
	-$(SUBMAKE) -C $(VPNC_DIR) clean
	$(RM) $(VPNC_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(VPNC_TARGET_BINARY)

$(PKG_FINISH)
