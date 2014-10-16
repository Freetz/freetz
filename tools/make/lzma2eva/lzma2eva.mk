LZMA2EVA_SOURCE:=lzma2eva.tar.bz2
LZMA2EVA_DIR:=$(TOOLS_SOURCE_DIR)/lzma2eva

LZMA2EVA_TOOLS:=lzma2eva eva2lzma

$(LZMA2EVA_DIR)/.unpacked: $(TOOLS_DIR)/source/$(LZMA2EVA_SOURCE) | $(TOOLS_SOURCE_DIR)
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xf $(TOOLS_DIR)/source/$(LZMA2EVA_SOURCE)
	touch $@

$(LZMA2EVA_TOOLS:%=$(LZMA2EVA_DIR)/%): $(LZMA2EVA_DIR)/.unpacked
	$(MAKE) CC="$(TOOLS_CC)" LD="$(TOOLS_LD)" -C $(LZMA2EVA_DIR)

$(LZMA2EVA_TOOLS:%=$(TOOLS_DIR)/%): $(TOOLS_DIR)/%: $(LZMA2EVA_DIR)/%
	cp $< $@

lzma2eva: $(LZMA2EVA_TOOLS:%=$(TOOLS_DIR)/%)

lzma2eva-source: $(LZMA2EVA_DIR)/.unpacked

lzma2eva-clean:
	-$(MAKE) -C $(LZMA2EVA_DIR) clean

lzma2eva-dirclean:
	$(RM) -r $(LZMA2EVA_DIR)

lzma2eva-distclean: lzma2eva-dirclean
	$(RM) $(LZMA2EVA_TOOLS:%=$(TOOLS_DIR)/%)
