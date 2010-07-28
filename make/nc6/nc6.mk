$(call PKG_INIT_BIN, 1.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=97fb6d871d804eabbc0ec6552d46b6b0
$(PKG)_SITE:=http://ftp.deepspace6.net/pub/ds6/sources/nc6/
$(PKG)_BINARY:=$($(PKG)_DIR)/src/nc6
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/nc6

$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),,--disable-ipv6)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(NC6_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(NC6_DIR) clean

$(pkg)-uninstall:
	$(RM) $(NC6_TARGET_BINARY)

$(PKG_FINISH)
