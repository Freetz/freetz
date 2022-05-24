$(call PKG_INIT_BIN, 1.2.2)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=f1ad05951bc0069d40123d2eca55fff7e922bced9161090a5ef25de5b6947034
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
