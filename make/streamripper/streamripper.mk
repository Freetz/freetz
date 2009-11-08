$(call PKG_INIT_BIN, 1.64.0)
$(PKG)_SOURCE:=streamripper-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=@SF/streamripper
$(PKG)_BINARY:=$($(PKG)_DIR)/streamripper
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/streamripper
$(PKG)_SOURCE_MD5:=f8754813ddc2bc96c4c3440e25aca8b6 

$(PKG)_DEPENDS_ON := glib2 libmad

$(PKG)_CONFIGURE_OPTIONS += --with-included-argv
$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PKG)_CONFIGURE_OPTIONS += --with-included-tre
$(PKG)_CONFIGURE_OPTIONS += --without-ogg
$(PKG)_CONFIGURE_OPTIONS += --without-vorbis
$(PKG)_CONFIGURE_OPTIONS += --disable-shared


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
		$(SUBMAKE) -C $(STREAMRIPPER_DIR) all

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg): 

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(STREAMRIPPER_DIR) clean

$(pkg)-uninstall:
	$(RM) $(STREAMRIPPER_TARGET_BINARY)

$(PKG_FINISH)
