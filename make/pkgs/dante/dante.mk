$(call PKG_INIT_BIN, 1.4.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=418a065fe1a4b8ace8fbf77c2da269a98f376e7115902e76cda7e741e4846a5d
$(PKG)_SITE:=https://www.inet.no/dante/files
### WEBSITE:=https://www.inet.no/dante/
### MANPAGE:=https://www.inet.no/dante/doc/1.4.x/index.html
### CHANGES:=https://www.inet.no/dante/index.html#Recent

$(PKG)_BINARY:=$($(PKG)_DIR)/sockd/sockd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/danted

$(PKG)_CONFIGURE_PRE_CMDS += autoreconf -i;

$(PKG)_CONFIGURE_OPTIONS += --with-libc=libc.so
$(PKG)_CONFIGURE_OPTIONS += --without-bsdauth
$(PKG)_CONFIGURE_OPTIONS += --without-gssapi
$(PKG)_CONFIGURE_OPTIONS += --without-glibc-secure
$(PKG)_CONFIGURE_OPTIONS += --without-sasl
$(PKG)_CONFIGURE_OPTIONS += --without-ldap
$(PKG)_CONFIGURE_OPTIONS += --without-upnp
$(PKG)_CONFIGURE_OPTIONS += --without-libwrap
$(PKG)_CONFIGURE_OPTIONS += --without-pam


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
