$(call PKG_INIT_BIN, 0.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://mkp.net/code/fstyp
$(PKG)_BINARY:=$($(PKG)_DIR)/src/fstyp
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/fstyp
$(PKG)_SOURCE_MD5:=05ea6ba0244df54ab2edba1f61734a32 

$(PKG)_CONFIGURE_PRE_CMDS += autoconf --force ;

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --with-gnu-ld


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(FSTYP_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(FSTYP_DIR) clean

$(pkg)-uninstall:
	$(RM) $(FSTYP_TARGET_BINARY)

$(PKG_FINISH)
