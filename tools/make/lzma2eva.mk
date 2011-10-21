LZMA2EVA_SOURCE:=lzma2eva.tar.bz2
LZMA2EVA_DIR:=$(TOOLS_SOURCE_DIR)/lzma2eva
LZMA2EVA_MAKE_DIR:=$(TOOLS_DIR)/make


$(LZMA2EVA_DIR)/.unpacked: $(TOOLS_DIR)/source/$(LZMA2EVA_SOURCE) | $(TOOLS_SOURCE_DIR)
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xjf $(TOOLS_DIR)/source/$(LZMA2EVA_SOURCE)
	for i in $(LZMA2EVA_MAKE_DIR)/patches/*.lzma2eva.patch; do \
		$(PATCH_TOOL) $(LZMA2EVA_DIR) $$i; \
	done
	touch $@

$(LZMA2EVA_DIR)/lzma2eva: $(LZMA2EVA_DIR)/.unpacked
	$(MAKE) CC="$(TOOLS_CC)" LD="$(TOOLS_LD)" -C $(LZMA2EVA_DIR)

$(TOOLS_DIR)/lzma2eva: $(LZMA2EVA_DIR)/lzma2eva
	cp $(LZMA2EVA_DIR)/lzma2eva $(TOOLS_DIR)/lzma2eva

lzma2eva: $(TOOLS_DIR)/lzma2eva

lzma2eva-source: $(LZMA2EVA_DIR)/.unpacked

lzma2eva-clean:
	-$(MAKE) -C $(LZMA2EVA_DIR) clean

lzma2eva-dirclean:
	$(RM) -r $(LZMA2EVA_DIR)

lzma2eva-distclean: lzma2eva-dirclean
	$(RM) $(TOOLS_DIR)/lzma2eva
