$(call PKG_INIT_BIN, 1.62.3)
$(PKG)_SOURCE:=streamripper-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://mesh.dl.sourceforge.net/sourceforge/streamripper
$(PKG)_BINARY:=$($(PKG)_DIR)/streamripper
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/streamripper

$(PKG)_DEPENDS_ON := libmad

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
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(STREAMRIPPER_DIR) all

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

streamripper: 

streamripper-precompiled: uclibc streamripper $($(PKG)_TARGET_BINARY)

streamripper-clean:
	-$(MAKE) -C $(STREAMRIPPER_DIR) clean

streamripper-uninstall:
	rm -f $(STREAMRIPPER_TARGET_BINARY)

$(PKG_FINISH)
