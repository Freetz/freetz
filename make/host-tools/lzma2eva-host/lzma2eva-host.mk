$(call TOOLS_INIT, 0)

$(PKG)_BINS:=lzma2eva eva2lzma bzimage2eva eva2bzimage


$(TOOLS_LOCALSOURCE_PACKAGE)
$(TOOLS_CONFIGURED_NOP)

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
