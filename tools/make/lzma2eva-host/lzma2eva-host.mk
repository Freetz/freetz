LZMA2EVA_HOST_SRC:=$(TOOLS_DIR)/make/lzma2eva-host/src
LZMA2EVA_HOST_DIR:=$(TOOLS_SOURCE_DIR)/lzma2eva

LZMA2EVA_HOST_TOOLS:=lzma2eva eva2lzma bzimage2eva eva2bzimage


lzma2eva-host-unpacked: $(LZMA2EVA_HOST_DIR)/.unpacked
$(LZMA2EVA_HOST_DIR)/.unpacked: $(wildcard $(LZMA2EVA_HOST_SRC)/*) | $(TOOLS_SOURCE_DIR) tar-host
	$(RM) -r $(LZMA2EVA_HOST_DIR)
	mkdir -p $(LZMA2EVA_HOST_DIR)
	$(call COPY_USING_TAR,$(LZMA2EVA_HOST_SRC),$(LZMA2EVA_HOST_DIR))
	touch $@

$(LZMA2EVA_HOST_TOOLS:%=$(LZMA2EVA_HOST_DIR)/%): $(LZMA2EVA_HOST_DIR)/.unpacked
	$(MAKE) CC="$(TOOLS_CC)" CXX="$(TOOLS_CXX)" CFLAGS="$(TOOLS_CFLAGS)" LDFLAGS="$(TOOLS_LDFLAGS)" -C $(LZMA2EVA_HOST_DIR) $(QUIET)

$(LZMA2EVA_HOST_TOOLS:%=$(TOOLS_DIR)/%): $(TOOLS_DIR)/%: $(LZMA2EVA_HOST_DIR)/%
	$(INSTALL_FILE)

lzma2eva-host-precompiled: $(LZMA2EVA_HOST_TOOLS:%=$(TOOLS_DIR)/%)


lzma2eva-host-clean:
	-$(MAKE) -C $(LZMA2EVA_HOST_DIR) clean

lzma2eva-host-dirclean:
	$(RM) -r $(LZMA2EVA_HOST_DIR)

lzma2eva-host-distclean: lzma2eva-host-dirclean
	$(RM) $(LZMA2EVA_HOST_TOOLS:%=$(TOOLS_DIR)/%)

