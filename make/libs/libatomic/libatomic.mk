$(call PKG_INIT_LIB, $(if $(FREETZ_TARGET_GCC_8),1.2.0,$(if $(FREETZ_TARGET_GCC_5),1.1.0,1.0.0)))
# Remove this later (when all .config are updated)
#$(call PKG_INIT_LIB, $(call qstrip,$(FREETZ_GNULIBATOMIC_VERSION)))

$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(pkg).so.$($(PKG)_VERSION)
$(PKG)_TARGET_BINARY:=$(if $(FREETZ_SEPARATE_AVM_UCLIBC),$($(PKG)_TARGET_DIR),$(TARGET_SPECIFIC_ROOT_DIR)/lib)/$(pkg).so.$($(PKG)_VERSION)


$($(PKG)_STAGING_BINARY): gcc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:

$(pkg)-uninstall:
	$(RM) $(TARGET_SPECIFIC_ROOT_DIR)/lib/libatomic.so*
	$(RM) $(LIBATOMIC_TARGET_DIR)/libatomic.so*

$(PKG_FINISH)

