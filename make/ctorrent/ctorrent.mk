PACKAGE_LC:=ctorrent
PACKAGE_UC:=CTORRENT
$(PACKAGE_UC)_VERSION:=dnh3.2
$(PACKAGE_INIT_BIN)
CTORRENT_SOURCE:=ctorrent-$(CTORRENT_VERSION).tar.gz
CTORRENT_SITE:=http://www.rahul.net/dholmes/ctorrent/
CTORRENT_BINARY:=$(CTORRENT_DIR)/ctorrent
CTORRENT_TARGET_BINARY:=$(CTORRENT_DEST_DIR)/usr/bin/ctorrent

$(PACKAGE_UC)_CONFIGURE_ENV += CXXFLAGS="-Os"
$(PACKAGE_UC)_CONFIGURE_ENV += CXX="mipsel-linux-g++-uc"
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --with-ssl=no


$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)
$(PACKAGE_CONFIGURED_CONFIGURE)
		
$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(CTORRENT_DIR) all

$($(PACKAGE_UC)_TARGET_BINARY): $($(PACKAGE_UC)_BINARY)
	$(INSTALL_BINARY_STRIP)

ctorrent: 

ctorrent-precompiled: uclibc uclibcxx-precompiled ctorrent $($(PACKAGE_UC)_TARGET_BINARY)

ctorrent-clean:
	-$(MAKE) -C $(CTORRENT_DIR) clean

ctorrent-uninstall:
	rm -f $(CTORRENT_TARGET_BINARY)

$(PACKAGE_FINI)
