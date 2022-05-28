$(call PKG_INIT_LIB,$(call qstrip,$(FREETZ_GNULIBSTDCXX_VERSION)),libstdcxx)
### VERSION:=6.0.16/6.0.17/6.0.19/6.0.20/6.0.21/6.0.25/6.0.28

$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libstdc++.so.$($(PKG)_VERSION)
$(PKG)_TARGET_BINARY:=$(if $(FREETZ_SEPARATE_AVM_UCLIBC),$($(PKG)_TARGET_DIR),$(TARGET_SPECIFIC_ROOT_DIR)/usr/lib)/libstdc++.so.$($(PKG)_VERSION)


$($(PKG)_STAGING_BINARY): gcc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:

$(pkg)-uninstall:
	$(RM) $(TARGET_SPECIFIC_ROOT_DIR)/usr/lib/libstdc++.so*
	$(RM) $(LIBSTDCXX_TARGET_DIR)/libstdc++.so*

$(PKG_FINISH)

