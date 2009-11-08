$(call PKG_INIT_BIN, 3.0.6)
$(PKG)_SOURCE:=rsync-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://samba.anu.edu.au/ftp/rsync
$(PKG)_BINARY:=$($(PKG)_DIR)/rsync
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/rsync
$(PKG)_SOURCE_MD5:=e9865d093a18e4668b9d31b635dc8e99 

$(PKG)_DEPENDS_ON := popt

$(PKG)_CONFIGURE_OPTIONS += --disable-iconv
$(PKG)_CONFIGURE_OPTIONS += --disable-locale
$(PKG)_CONFIGURE_OPTIONS += --without-included-popt
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),,--disable-ipv6)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
		$(SUBMAKE) -C $(RSYNC_DIR) \
		CC="$(TARGET_CC)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(RSYNC_DIR) clean
	$(RM) $(RSYNC_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(RSYNC_TARGET_BINARY)

$(PKG_FINISH)
