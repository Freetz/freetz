$(call TOOLS_INIT, 0)

$(PKG)_BINS:=lzma2eva eva2lzma bzimage2eva eva2bzimage


$(pkg)-unpacked: $($(PKG)_DIR)/.unpacked
$($(PKG)_DIR)/.unpacked: $(wildcard $($(PKG)_SRC)/*) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(RM) -r $(LZMA2EVA_HOST_DIR)
	mkdir -p $(LZMA2EVA_HOST_DIR)
	$(call COPY_USING_TAR,$(LZMA2EVA_HOST_SRC),$(LZMA2EVA_HOST_DIR))
	touch $@

$($(PKG)_BINS:%=$($(PKG)_DIR)/%): $($(PKG)_DIR)/.unpacked
	$(TOOLS_SUBMAKE) CC="$(TOOLS_CC)" CXX="$(TOOLS_CXX)" CFLAGS="$(TOOLS_CFLAGS)" LDFLAGS="$(TOOLS_LDFLAGS)" -C $(LZMA2EVA_HOST_DIR)

$($(PKG)_BINS:%=$(TOOLS_DIR)/%): $(TOOLS_DIR)/%: $($(PKG)_DIR)/%
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_BINS:%=$(TOOLS_DIR)/%)


$(pkg)-clean:
	-$(MAKE) -C $(LZMA2EVA_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(LZMA2EVA_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(LZMA2EVA_HOST_BINS:%=$(TOOLS_DIR)/%)

$(TOOLS_FINISH)
