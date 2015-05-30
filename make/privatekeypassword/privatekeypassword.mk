$(call PKG_INIT_BIN, 0.1)

$(PKG)_BINARY:=$($(PKG)_DIR)/getprivkeypass-ftpd-proxy
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/bin/getprivkeypass-ftpd-proxy

$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/libprivatekeypassword.so
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libprivatekeypassword.so
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_TARGET_LIBDIR)/libprivatekeypassword.so

$(PKG_LOCALSOURCE_PACKAGE)
$(PKG_CONFIGURED_NOP)

$($(PKG)_LIB_BINARY) $($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(PRIVATEKEYPASSWORD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		AR="$(TARGET_AR)" \
		RANLIB="$(TARGET_RANLIB)"

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	$(SUBMAKE) -C $(PRIVATEKEYPASSWORD_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install-lib

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_LIB_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(PRIVATEKEYPASSWORD_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libprivatekeypassword* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/privatekeypassword

$(pkg)-uninstall:
	$(RM) \
		$(PRIVATEKEYPASSWORD_TARGET_BINARY) \
		$(PRIVATEKEYPASSWORD_TARGET_LIBDIR)/libprivatekeypassword.so*

$(call PKG_ADD_LIB,libprivatekeypassword)
$(PKG_FINISH)
