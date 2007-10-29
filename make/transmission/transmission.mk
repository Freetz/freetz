PACKAGE_LC:=transmission
PACKAGE_UC:=TRANSMISSION
$(PACKAGE_UC)_VERSION:=0.82
$(PACKAGE_INIT_BIN)
$(PACKAGE_UC)_SOURCE:=transmission-$($(PACKAGE_UC)_VERSION).tar.bz2
#$(PACKAGE_UC)_SITE:=http://download.m0k.org/transmission/files
$(PACKAGE_UC)_SITE:=http://dsmod.magenbrot.net
$(PACKAGE_UC)_BINARY:=$($(PACKAGE_UC)_DIR)/cli/transmissioncli
$(PACKAGE_UC)_TARGET_BINARY:=$($(PACKAGE_UC)_DEST_DIR)/usr/bin/transmissioncli

$(PACKAGE_UC)_CONFIGURE_ENV += CROSS="$(TARGET_CROSS)"
$(PACKAGE_UC)_CONFIGURE_ENV += CC="$(TARGET_CC)"
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-gtk
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-openssl


$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)
$(PACKAGE_CONFIGURED_CONFIGURE)

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(TRANSMISSION_DIR)

$($(PACKAGE_UC)_TARGET_BINARY): $($(PACKAGE_UC)_BINARY)
	$(INSTALL_BINARY_STRIP)

transmission: 

transmission-precompiled: libevent-precompiled transmission $($(PACKAGE_UC)_TARGET_BINARY)

transmission-clean:
	-$(MAKE) -C $(TRANSMISSION_DIR) clean

transmission-uninstall:
	rm -f $(TRANSMISSION_TARGET_BINARY)

$(PACKAGE_FINI)
