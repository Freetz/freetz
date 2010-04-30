$(call PKG_INIT_BIN, 2.23)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=ftp://ftp.infradead.org/pub/$(pkg)
$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/sbin/$(pkg)
$(PKG)_STARTLEVEL=40
$(PKG)_SOURCE_MD5:=5ed49f23c642a29848cb2dbcfa96dfce

$(PKG)_DEPENDS_ON := libxml2 zlib openssl

#$(PKG)_SSL_CFLAGS := -I$(TARGET_TOOLCHAIN_STAGING_DIR)/include/openssl

$(PKG)_LIBS := -lcrypto -lssl
#$(PKG)_SSL_LDFLAGS := -lcrypto -lssl

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENCONNECT_NAT_SUPPORT

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(OPENCONNECT_DIR) openconnect \
		CC="$(TARGET_CC)" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" \
		EXTRA_LDFLAGS="$(OPENCONNECT_LIBS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

#$(PKG)_NAT_SUPPORT: $(PACKAGES_DIR)/.$(pkg)-$($(PKG)_VERSION)
#ifeq ($(strip $(FREETZ_PACKAGE_OPENCONNECT_NAT_SUPPORT)),y)
#	@$(SED) -i -e 's/#start_vpn_nat/start_vpn_nat/g' $(OPENCONNECT_DEST_DIR)/etc/default.openconnect/openconnect-script
#	@$(SED) -i -e 's/#stop_vpn_nat/stop_vpn_nat/g' $(OPENCONNECT_DEST_DIR)/etc/default.openconnect/openconnect-script
#endif

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) #$(PKG)_NAT_SUPPORT

$(pkg)-clean:
	-$(SUBMAKE) -C $(OPENCONNECT_DIR) clean
	$(RM) $(OPENCONNECT_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(OPENCONNECT_TARGET_BINARY)

$(PKG_FINISH)
