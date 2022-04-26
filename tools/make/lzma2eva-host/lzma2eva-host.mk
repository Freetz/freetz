$(call TOOL_INIT, 0)

$(TOOL)_BINS:=lzma2eva eva2lzma bzimage2eva eva2bzimage


$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(wildcard $($(TOOL)_SRC)/*) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(RM) -r $(LZMA2EVA_HOST_DIR)
	mkdir -p $(LZMA2EVA_HOST_DIR)
	$(call COPY_USING_TAR,$(LZMA2EVA_HOST_SRC),$(LZMA2EVA_HOST_DIR))
	touch $@

$($(TOOL)_BINS:%=$($(TOOL)_DIR)/%): $($(TOOL)_DIR)/.unpacked
	$(TOOL_SUBMAKE) CC="$(TOOLS_CC)" CXX="$(TOOLS_CXX)" CFLAGS="$(TOOLS_CFLAGS)" LDFLAGS="$(TOOLS_LDFLAGS)" -C $(LZMA2EVA_HOST_DIR)

$($(TOOL)_BINS:%=$(TOOLS_DIR)/%): $(TOOLS_DIR)/%: $($(TOOL)_DIR)/%
	$(INSTALL_FILE)

$(tool)-precompiled: $($(TOOL)_BINS:%=$(TOOLS_DIR)/%)


$(tool)-clean:
	-$(MAKE) -C $(LZMA2EVA_HOST_DIR) clean

$(tool)-dirclean:
	$(RM) -r $(LZMA2EVA_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean
	$(RM) $(LZMA2EVA_HOST_BINS:%=$(TOOLS_DIR)/%)

$(TOOL_FINISH)
