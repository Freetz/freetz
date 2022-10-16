$(call TOOLS_INIT, 0)


$(TOOLS_LOCALSOURCE_PACKAGE)
$(TOOLS_CONFIGURED_NOP)

$($(PKG)_DIR)/tichksum: $($(PKG)_DIR)/.unpacked
	$(TOOLS_SUBMAKE) CC="$(TOOLS_CC)" CXX="$(TOOLS_CXX)" CFLAGS="$(TOOLS_CFLAGS)" LDFLAGS="$(TOOLS_LDFLAGS)" -C $(TICHKSUM_HOST_DIR)

$(TOOLS_DIR)/tichksum: $($(PKG)_DIR)/tichksum
	$(INSTALL_FILE)

$(pkg)-precompiled: $(TOOLS_DIR)/tichksum


$(pkg)-clean:
	-$(MAKE) -C $(TICHKSUM_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(TICHKSUM_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(TOOLS_DIR)/tichksum

$(TOOLS_FINISH)
