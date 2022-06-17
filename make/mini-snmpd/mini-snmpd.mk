$(call PKG_INIT_BIN,1.6)
$(PKG)_SOURCE:=mini-snmpd-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=77bc704a4ed4fdc386e2ba2e972d9457564c84abef7e9af5de5a2a231e5a9efe
$(PKG)_SITE:=https://github.com/troglobit/mini-snmpd/releases/download/v$($(PKG)_VERSION)
### WEBSITE:=https://troglobit.com/projects/mini-snmpd/
### MANPAGE:=https://ftp.troglobit.com/mini-snmpd/mini-snmpd.html
### CHANGES:=https://github.com/troglobit/mini-snmpd/releases
### CVSREPO:=https://github.com/troglobit/mini-snmpd

$(PKG)_BINARY:=$($(PKG)_DIR)/mini-snmpd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/mini-snmpd

$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(MINI_SNMPD_DIR) \
		CC="$(TARGET_CC)" \
		STRIP="$(TARGET_STRIP)" \
		OFLAGS="$(TARGET_CFLAGS) $(MINI_SNMPD_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(MINI_SNMPD_DIR) clean

$(pkg)-uninstall:
	$(RM) $(MINI_SNMPD_TARGET_BINARY)

$(PKG_FINISH)
