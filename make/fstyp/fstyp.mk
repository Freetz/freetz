$(call PKG_INIT_BIN, 0.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://mkp.net/code/fstyp
$(PKG)_BINARY:=$($(PKG)_DIR)/src/fstyp
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/fstyp

$(PKG)_CONFIGURE_PRE_CMDS += autoconf --force ;

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --with-gnu-ld


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(FSTYP_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

fstyp:

fstyp-precompiled: $($(PKG)_TARGET_BINARY)

fstyp-clean:
	-$(MAKE) -C $(FSTYP_DIR) clean

fstyp-uninstall:
	rm -f $(FSTYP_TARGET_BINARY)

$(PKG_FINISH)
