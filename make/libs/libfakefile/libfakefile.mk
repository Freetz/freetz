$(call PKG_INIT_LIB, 0.0)

$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg).so.$($(PKG)_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_LIB)/$(pkg).so.$($(PKG)_VERSION)

$(PKG_LOCALSOURCE_PACKAGE)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBFAKEFILE_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LIB_VERSION="$(LIBFAKEFILE_VERSION)" \
		all

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBFAKEFILE_DIR) clean

$(pkg)-uninstall:
	$(RM) $(LIBFAKEFILE_DEST_LIB)/libfakefile*.so*

$(PKG_FINISH)
