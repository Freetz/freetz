LZMA2EVA_SRC:=$(TOOLS_DIR)/make/lzma2eva/src
LZMA2EVA_DIR:=$(TOOLS_SOURCE_DIR)/lzma2eva

LZMA2EVA_TOOLS:=lzma2eva eva2lzma bzimage2eva eva2bzimage

lzma2eva-unpacked: $(LZMA2EVA_DIR)/.unpacked
$(LZMA2EVA_DIR)/.unpacked: $(wildcard $(LZMA2EVA_SRC)/*) | $(TOOLS_SOURCE_DIR) tar-host
	$(RM) -r $(LZMA2EVA_DIR)
	mkdir -p $(LZMA2EVA_DIR)
	$(call COPY_USING_TAR,$(LZMA2EVA_SRC),$(LZMA2EVA_DIR))
	touch $@

$(LZMA2EVA_TOOLS:%=$(LZMA2EVA_DIR)/%): $(LZMA2EVA_DIR)/.unpacked
	$(MAKE) CC="$(TOOLS_CC)" -C $(LZMA2EVA_DIR)

$(LZMA2EVA_TOOLS:%=$(TOOLS_DIR)/%): $(TOOLS_DIR)/%: $(LZMA2EVA_DIR)/%
	$(INSTALL_FILE)

lzma2eva: $(LZMA2EVA_TOOLS:%=$(TOOLS_DIR)/%)

lzma2eva-clean:
	-$(MAKE) -C $(LZMA2EVA_DIR) clean

lzma2eva-dirclean:
	$(RM) -r $(LZMA2EVA_DIR)

lzma2eva-distclean: lzma2eva-dirclean
	$(RM) $(LZMA2EVA_TOOLS:%=$(TOOLS_DIR)/%)
