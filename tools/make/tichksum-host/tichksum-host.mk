$(call TOOL_INIT, 0)


$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(wildcard $($(TOOL)_SRC)/*) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(RM) -r $(TICHKSUM_HOST_DIR)
	mkdir -p $(TICHKSUM_HOST_DIR)
	$(call COPY_USING_TAR,$(TICHKSUM_HOST_SRC),$(TICHKSUM_HOST_DIR))
	touch $@

$($(TOOL)_DIR)/tichksum: $($(TOOL)_DIR)/.unpacked
	$(TOOL_SUBMAKE) CC="$(TOOLS_CC)" CXX="$(TOOLS_CXX)" CFLAGS="$(TOOLS_CFLAGS)" LDFLAGS="$(TOOLS_LDFLAGS)" -C $(TICHKSUM_HOST_DIR)

$(TOOLS_DIR)/tichksum: $($(TOOL)_DIR)/tichksum
	$(INSTALL_FILE)

$(tool)-precompiled: $(TOOLS_DIR)/tichksum


$(tool)-clean:
	-$(MAKE) -C $(TICHKSUM_HOST_DIR) clean

$(tool)-dirclean:
	$(RM) -r $(TICHKSUM_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean
	$(RM) $(TOOLS_DIR)/tichksum

$(TOOL_FINISH)
