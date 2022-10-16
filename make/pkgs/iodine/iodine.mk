$(call PKG_INIT_BIN,0.7.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=ad2b40acf1421316ec15800dcde0f587ab31d7d6f891fa8b9967c4ded93c013e
$(PKG)_SITE:=http://code.kryo.se/iodine
$(PKG)_BINARY:=$($(PKG)_DIR)/bin/iodined
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/iodined

$(PKG)_DEPENDS_ON += zlib

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(IODINE_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -c -DLINUX" \
		LDFLAGS="$(TARGET_LDFLAGS) -lz"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(IODINE_DIR) clean

$(pkg)-uninstall:
	$(RM) $(IODINE_TARGET_BINARY)

$(PKG_FINISH)
