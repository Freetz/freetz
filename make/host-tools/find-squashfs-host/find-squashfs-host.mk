$(call TOOLS_INIT, 0)


$(TOOLS_LOCALSOURCE_PACKAGE)
$(TOOLS_CONFIGURED_NOP)

$($(PKG)_DIR)/find-squashfs: $($(PKG)_DIR)/.unpacked
	$(TOOLS_SUBMAKE) CC="$(TOOLS_CC)" CXX="$(TOOLS_CXX)" CFLAGS="$(TOOLS_CFLAGS)" LDFLAGS="$(TOOLS_LDFLAGS)" -C $(FIND_SQUASHFS_HOST_DIR)

$(TOOLS_DIR)/find-squashfs: $($(PKG)_DIR)/find-squashfs
	$(INSTALL_FILE)

$(pkg)-precompiled: $(TOOLS_DIR)/find-squashfs


$(pkg)-clean:
	-$(MAKE) -C $(FIND_SQUASHFS_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(FIND_SQUASHFS_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(TOOLS_DIR)/find-squashfs

$(TOOLS_FINISH)
