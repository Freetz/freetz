$(call PKG_INIT_BIN, 1.2.2)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=69b9d6234154d7d6a91fcbd98c68e62a
$(PKG)_SITE:=http://www.inet.no/dante/files

$(PKG)_BINARY:=$($(PKG)_DIR)/sockd/sockd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/danted

$(PKG)_CONFIGURE_OPTIONS += --with-libc=libc.so
$(PKG)_CONFIGURE_OPTIONS += --disable-libwrap
$(PKG)_CONFIGURE_OPTIONS += --without-glibc-secure
$(PKG)_CONFIGURE_OPTIONS += --without-pam
$(PKG)_CONFIGURE_OPTIONS += --without-upnp

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(DANTE_DIR) all

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(DANTE_DIR) clean

$(pkg)-uninstall:
	$(RM) $(DANTE_TARGET_BINARY)

$(PKG_FINISH)
