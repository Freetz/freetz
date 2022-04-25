AVM_RLE_HOST_SRC:=$(TOOLS_DIR)/make/avm-rle-host/src
AVM_RLE_HOST_DIR:=$(TOOLS_SOURCE_DIR)/avm-rle


avm-rle-host-unpacked: $(AVM_RLE_HOST_DIR)/.unpacked
$(AVM_RLE_HOST_DIR)/.unpacked: $(wildcard $(AVM_RLE_HOST_SRC)/*) | $(TOOLS_SOURCE_DIR) tar-host
	$(RM) -r $(AVM_RLE_HOST_DIR)
	mkdir -p $(AVM_RLE_HOST_DIR)
	$(call COPY_USING_TAR,$(AVM_RLE_HOST_SRC),$(AVM_RLE_HOST_DIR))
	touch $@

$(AVM_RLE_HOST_DIR)/avm-rle-decode: $(AVM_RLE_HOST_DIR)/.unpacked
	$(TOOL_SUBMAKE) CC="$(TOOLS_CC)" CXX="$(TOOLS_CXX)" CFLAGS="$(TOOLS_CFLAGS)" LDFLAGS="$(TOOLS_LDFLAGS)" -C $(AVM_RLE_HOST_DIR)

$(TOOLS_DIR)/avm-rle-decode: $(AVM_RLE_HOST_DIR)/avm-rle-decode
	$(INSTALL_FILE)

$(TOOLS_DIR)/avm-rle-stream-length: $(TOOLS_DIR)/avm-rle-decode
	ln -sf $(notdir $<) $@

avm-rle-host-precompiled: $(TOOLS_DIR)/avm-rle-decode $(TOOLS_DIR)/avm-rle-stream-length


avm-rle-host-clean:
	-$(MAKE) -C $(AVM_RLE_HOST_DIR) clean

avm-rle-host-dirclean:
	$(RM) -r $(AVM_RLE_HOST_DIR)

avm-rle-host-distclean: avm-rle-host-dirclean
	$(RM) $(TOOLS_DIR)/avm-rle-*

