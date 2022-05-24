$(call TOOLS_INIT, 0)


$(TOOLS_LOCALSOURCE_PACKAGE)
$(TOOLS_CONFIGURED_NOP)

$($(PKG)_DIR)/avm-rle-decode: $($(PKG)_DIR)/.unpacked
	$(TOOLS_SUBMAKE) CC="$(TOOLS_CC)" CXX="$(TOOLS_CXX)" CFLAGS="$(TOOLS_CFLAGS)" LDFLAGS="$(TOOLS_LDFLAGS)" -C $(AVM_RLE_HOST_DIR)

$(TOOLS_DIR)/avm-rle-decode: $($(PKG)_DIR)/avm-rle-decode
	$(INSTALL_FILE)

$(TOOLS_DIR)/avm-rle-stream-length: $(TOOLS_DIR)/avm-rle-decode
	ln -sf $(notdir $<) $@

$(pkg)-precompiled: $(TOOLS_DIR)/avm-rle-decode $(TOOLS_DIR)/avm-rle-stream-length


$(pkg)-clean:
	-$(MAKE) -C $(AVM_RLE_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(AVM_RLE_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(TOOLS_DIR)/avm-rle-*

$(TOOLS_FINISH)
