$(call PKG_INIT_BIN, 0.1)
$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_USR_BIN)/$(pkg)

$(PKG_LOCALSOURCE_PACKAGE)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	(cd $(MINISTUN_DIR); \
		$(TARGET_CC) $(TARGET_CFLAGS) -o ministun ministun.c \
	)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	$(RM) $(MINISTUN_BINARY) $(MINISTUN_DIR)/*.o

$(pkg)-uninstall:
	$(RM) $(MINISTUN_TARGET_BINARY)

$(PKG_FINISH)
