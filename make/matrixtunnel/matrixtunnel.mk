$(eval $(call PKG_INIT_BIN, 0.2))
$(PKG)_SOURCE:=matrixtunnel-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://znerol.ch/files
$(PKG)_DIR:=$(SOURCE_DIR)/matrixtunnel
$(PKG)_BINARY:=$($(PKG)_DIR)/src/matrixtunnel
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/matrixtunnel

$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libintl-prefix
$(PKG)_CONFIGURE_OPTIONS += --with-matrixssl-src="$(DSMOD_BASE_DIR)/$(MATRIXSSL_DIR)"
$(PKG)_CONFIGURE_OPTIONS += LDFLAGS="-lpthread"


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(MATRIXTUNNEL_DIR)/src all
		
$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY) 
	$(INSTALL_BINARY_STRIP)

matrixtunnel:

matrixtunnel-precompiled: uclibc matrixssl-precompiled matrixtunnel $($(PKG)_TARGET_BINARY) 

matrixtunnel-clean:
	-$(MAKE) -C $(MATRIXTUNNEL_DIR)/src clean
	rm -f $(PACKAGES_BUILD_DIR)/$(MATRIXTUNNEL_PKG_SOURCE)

matrixtunnel-uninstall: 
	rm -f $(MATRIXTUNNEL_TARGET_BINARY)
  
$(PKG_FINISH)
