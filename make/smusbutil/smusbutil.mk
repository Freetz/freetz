$(call PKG_INIT_BIN, 1.1)
$(PKG)_SOURCE:=$(pkg).tar.bz2
$(PKG)_HASH:=4b7d09e87214076c57937d5c280f088cf15e0f05f77bd3a06e64f02a1847ace8
$(PKG)_SITE:=http://www.wbe.se/files

$(PKG)_BINARY:=$($(PKG)_DIR)/smusbutil
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/smusbutil

$(PKG)_DEPENDS_ON += libftdi

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SMUSBUTIL_DIR)  \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SMUSBUTIL_DIR) clean

$(pkg)-uninstall:
	$(RM) $(SMUSBUTIL_TARGET_BINARY)

$(PKG_FINISH)

