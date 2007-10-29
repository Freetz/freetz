PACKAGE_LC:=streamripper
PACKAGE_UC:=STREAMRIPPER
$(PACKAGE_UC)_VERSION:=1.62.3
$(PACKAGE_INIT_BIN)
$(PACKAGE_UC)_SOURCE:=streamripper-$($(PACKAGE_UC)_VERSION).tar.gz
$(PACKAGE_UC)_SITE:=http://mesh.dl.sourceforge.net/sourceforge/streamripper
$(PACKAGE_UC)_BINARY:=$($(PACKAGE_UC)_DIR)/streamripper
$(PACKAGE_UC)_TARGET_BINARY:=$($(PACKAGE_UC)_DEST_DIR)/usr/bin/streamripper

$(PACKAGE_UC)_CONFIGURE_OPTIONS += --with-included-argv
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --with-included-tre
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --without-ogg
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --without-vorbis
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-shared


$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)
$(PACKAGE_CONFIGURED_CONFIGURE)

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(STREAMRIPPER_DIR) all

$($(PACKAGE_UC)_TARGET_BINARY): $($(PACKAGE_UC)_BINARY)
	$(INSTALL_BINARY_STRIP)

streamripper: 

streamripper-precompiled: uclibc mad-precompiled streamripper $($(PACKAGE_UC)_TARGET_BINARY)

streamripper-clean:
	-$(MAKE) -C $(STREAMRIPPER_DIR) clean

streamripper-uninstall:
	rm -f $(STREAMRIPPER_TARGET_BINARY)

$(PACKAGE_FINI)
