$(call PKG_INIT_LIB, 1)

$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(pkg).so.$($(PKG)_VERSION)
$(PKG)_TARGET_BINARY:=$(TARGET_SPECIFIC_ROOT_DIR)/lib/$(pkg).so.$($(PKG)_VERSION)

$($(PKG)_STAGING_BINARY): gcc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:

$(pkg)-uninstall:
	$(RM) $(TARGET_SPECIFIC_ROOT_DIR)/lib/libgcc_s.so*

$(PKG_FINISH)
