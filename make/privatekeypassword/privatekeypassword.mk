$(call PKG_INIT_BIN, 221a16bf47)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=X
$(PKG)_SITE:=git@https://github.com/PeterPawn/$(pkg).git

$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/bin/$(pkg)

$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/src/lib$(pkg).so
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib$(pkg).so
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_TARGET_LIBDIR)/lib$(pkg).so

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_LIB_BINARY) $($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(PRIVATEKEYPASSWORD_DIR)/src \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CC_OPT="" \
		AR="$(TARGET_AR)" \
		RANLIB="$(TARGET_RANLIB)"

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	$(SUBMAKE) -C $(PRIVATEKEYPASSWORD_DIR)/src \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install-lib

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_LIB_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(PRIVATEKEYPASSWORD_DIR)/src clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libprivatekeypassword* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/privatekeypassword

$(pkg)-uninstall:
	$(RM) \
		$(PRIVATEKEYPASSWORD_TARGET_BINARY) \
		$(PRIVATEKEYPASSWORD_TARGET_LIBDIR)/libprivatekeypassword.so*

$(call PKG_ADD_LIB,libprivatekeypassword)
$(PKG_FINISH)
