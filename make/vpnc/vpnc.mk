$(call PKG_INIT_BIN, 0.5.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.unix-ag.uni-kl.de/~massar/vpnc
$(PKG)_BINARY:=$($(PKG)_DIR)/vpnc
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/sbin/vpnc
$(PKG)_STARTLEVEL=40

$(PKG)_DEPENDS_ON := libgpg-error libgcrypt

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_VPNC_WITH_HYBRID_AUTH

ifeq ($(strip $(FREETZ_PACKAGE_VPNC_WITH_HYBRID_AUTH)),y)
VPNC_CPPFLAGS := -DOPENSSL_GPL_VIOLATION
VPNC_LDFLAGS := -lcrypto
$(PKG)_DEPENDS_ON += openssl
else
VPNC_CPPFLAGS :=
VPNC_LDFLAGS :=
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_PATH) \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include $(VPNC_CPPFLAGS)" \
		$(MAKE) -C $(VPNC_DIR) vpnc \
		CC="$(TARGET_CC)" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" \
		EXTRA_LDFLAGS="-L$(TARGET_MAKE_PATH)/../usr/lib $(VPNC_LDFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(VPNC_DIR) clean
	$(RM) $(VPNC_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(VPNC_TARGET_BINARY)

$(PKG_FINISH)
