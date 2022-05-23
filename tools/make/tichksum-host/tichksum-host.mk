$(call TOOLS_INIT, 0)


$(pkg)-unpacked: $($(PKG)_DIR)/.unpacked
$($(PKG)_DIR)/.unpacked: $(wildcard $($(PKG)_SRC)/*) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(RM) -r $(TICHKSUM_HOST_DIR)
	mkdir -p $(TICHKSUM_HOST_DIR)
	$(call COPY_USING_TAR,$(TICHKSUM_HOST_SRC),$(TICHKSUM_HOST_DIR))
	touch $@

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
