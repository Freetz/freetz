$(call TOOL_INIT, 0)


$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(wildcard $($(TOOL)_SRC)/*) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(RM) -r $(AVM_RLE_HOST_DIR)
	mkdir -p $(AVM_RLE_HOST_DIR)
	$(call COPY_USING_TAR,$(AVM_RLE_HOST_SRC),$(AVM_RLE_HOST_DIR))
	touch $@

$($(TOOL)_DIR)/avm-rle-decode: $($(TOOL)_DIR)/.unpacked
	$(TOOL_SUBMAKE) CC="$(TOOLS_CC)" CXX="$(TOOLS_CXX)" CFLAGS="$(TOOLS_CFLAGS)" LDFLAGS="$(TOOLS_LDFLAGS)" -C $(AVM_RLE_HOST_DIR)

$(TOOLS_DIR)/avm-rle-decode: $($(TOOL)_DIR)/avm-rle-decode
	$(INSTALL_FILE)

$(TOOLS_DIR)/avm-rle-stream-length: $(TOOLS_DIR)/avm-rle-decode
	ln -sf $(notdir $<) $@

$(tool)-precompiled: $(TOOLS_DIR)/avm-rle-decode $(TOOLS_DIR)/avm-rle-stream-length


$(tool)-clean:
	-$(MAKE) -C $(AVM_RLE_HOST_DIR) clean

$(tool)-dirclean:
	$(RM) -r $(AVM_RLE_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean
	$(RM) $(TOOLS_DIR)/avm-rle-*

$(TOOL_FINISH)
