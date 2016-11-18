$(call PKG_INIT_BIN, 1.7.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=95df7262964dc22da62f7f6f0466c50e
$(PKG)_SITE:=https://download.dnscrypt.org/dnscrypt-proxy/

$(PKG)_BINARY:=$($(PKG)_DIR)/src/proxy/dnscrypt-proxy
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/dnscrypt-proxy

$(PKG)_DEPENDS_ON += libsodium

$(PKG)_CONFIGURE_DEFOPTS := n
$(PKG)_CONFIGURE_ENV += CC="$(TARGET_CC)"
$(PKG)_CONFIGURE_ENV += CFLAGS="$(TARGET_CFLAGS)"
$(PKG)_CONFIGURE_ENV += LDFLAGS="$(TARGET_LDFLAGS)"
$(PKG)_CONFIGURE_ENV += AR="$(TARGET_AR)"
$(PKG)_CONFIGURE_ENV += RANLIB="$(TARGET_RANLIB)"
$(PKG)_CONFIGURE_ENV += NM="$(TARGET_NM)"
$(PKG)_CONFIGURE_OPTIONS += --host "$(GNU_TARGET_NAME)" --disable-largefile --prefix=/usr

$(PKG)_RESOLVERS_FILE:=$($(PKG)_DIR)/dnscrypt-resolvers.csv
$(PKG)_TARGET_RESOLVERS_FILE:=$($(PKG)_DEST_DIR)/usr/share/dnscrypt-proxy/dnscrypt-resolvers.csv

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)


$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(DNSCRYPT_PROXY_DIR) \
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

ifeq ($(strip $(FREETZ_PACKAGE_$(PKG)_RESOLVERS)),y)
$($(PKG)_TARGET_RESOLVERS_FILE): $($(PKG)_RESOLVERS_FILE)
	$(INSTALL_FILE)
else
$($(PKG)_TARGET_RESOLVERS_FILE):
endif

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_RESOLVERS_FILE)

$(pkg)-clean:
	-$(SUBMAKE) -C $(DNSCRYPT_PROXY_DIR) clean
	$(RM) $(DNSCRYPT_PROXY_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(DNSCRYPT_PROXY_TARGET_BINARY) $(DNSCRYPT_PROXY_TARGET_RESOLVERS_FILE)

$(PKG_FINISH)
