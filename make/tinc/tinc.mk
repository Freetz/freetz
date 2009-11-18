$(call PKG_INIT_BIN, 1.0.8)
$(PKG)_SOURCE:=tinc-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.tinc-vpn.org/packages/
$(PKG)_DIR:=$(SOURCE_DIR)/tinc-$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/src/tincd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/tincd
$(PKG)_SOURCE_MD5:=1b59583b5bc57806459c81a413fb0cc4

$(PKG)_DEPENDS_ON := openssl
$(PKG)_DEPENDS_ON += lzo
$(PKG)_DEPENDS_ON += zlib

TINC_LIBS := -lssl -lcrypto -llzo2 -lz -ldl

ifeq ($(strip $(FREETZ_PACKAGE_TINC_STATIC)),y)
TINC_LDFLAGS := -static 
endif

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_TINC_STATIC

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(TINC_DIR) \
		LDFLAGS="$(TINC_LDFLAGS)" \
		LIBS="$(TINC_LIBS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(TINC_DIR) clean
	$(RM) $(TINC_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(TINC_TARGET_BINARY)

$(PKG_FINISH)
