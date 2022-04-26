$(call TOOL_INIT, 1.9.7)
$(TOOL)_SOURCE:=sfk-$($(TOOL)_VERSION).tar.gz
$(TOOL)_SOURCE_MD5:=99225c1ab3fe87af6c275724ab635ae0
$(TOOL)_SITE:=@SF/swissfileknife


$(tool)-source: $(DL_DIR)/$($(TOOL)_SOURCE)
$(DL_DIR)/$($(TOOL)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(SFK_HOST_SOURCE) $(SFK_HOST_SITE) $(SFK_HOST_SOURCE_MD5)

$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(DL_DIR)/$($(TOOL)_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(SFK_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(SFK_HOST_MAKE_DIR)/patches,$(SFK_HOST_DIR))
	touch $@

$($(TOOL)_DIR)/.configured: $($(TOOL)_DIR)/.unpacked
	(cd $(SFK_HOST_DIR); $(RM) config.cache; \
		CC="$(TOOLS_CC)" \
		CXX="$(TOOLS_CXX)" \
		CFLAGS="$(TOOLS_CFLAGS)" \
		LDFLAGS="$(TOOLS_LDFLAGS)" \
		./configure \
		--prefix=$(FREETZ_BASE_DIR)/$(TOOLS_DIR) \
		$(DISABLE_NLS) \
		$(SILENT) \
	);
	touch $@

$($(TOOL)_DIR)/sfk: $($(TOOL)_DIR)/.configured
	$(TOOL_SUBMAKE) -C $(SFK_HOST_DIR) all

$(TOOLS_DIR)/sfk: $($(TOOL)_DIR)/sfk
	$(INSTALL_FILE)

$(tool)-precompiled: $(TOOLS_DIR)/sfk


$(tool)-clean:
	-$(MAKE) -C $(SFK_HOST_DIR) clean

$(tool)-dirclean:
	$(RM) -r $(SFK_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean
	$(RM) $(TOOLS_DIR)/sfk

$(TOOL_FINISH)
