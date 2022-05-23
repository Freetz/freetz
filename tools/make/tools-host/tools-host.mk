$(call TOOL_INIT, 2022-05-23)
$(TOOL)_SOURCE:=tools-$($(TOOL)_VERSION).tar.xz
$(TOOL)_SOURCE_SHA256:=8ea529871b82e9bdeceb787409cfb080b3162d5a3c69a3dd22bc520fd6f97a77
$(TOOL)_SITE:=@MIRROR/


$(tool)-source: $(DL_DIR)/$($(TOOL)_SOURCE)
$(DL_DIR)/$($(TOOL)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(TOOLS_HOST_SOURCE) $(TOOLS_HOST_SITE) $(TOOLS_HOST_SOURCE_SHA256)
#	$(info ERROR: File '$(DL_DIR)/$(TOOLS_HOST_SOURCE)' not found.)
#	$(info There is and will no download source be available.)
#	$(info Either disable 'FREETZ_HOSTTOOLS_DOWNLOAD' in menuconfig)
#	$(info or create the file by yourself with 'tools/own-hosttools'.)
#	$(error )

$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(DL_DIR)/$($(TOOL)_SOURCE) | $(TOOLS_SOURCE_DIR)
	mkdir -p $(TOOLS_HOST_DIR)
	tar -C $(TOOLS_HOST_DIR) $(VERBOSE) -xf $(DL_DIR)/$(TOOLS_HOST_SOURCE)
	touch $@

$($(TOOL)_DIR)/.installed: $($(TOOL)_DIR)/.unpacked
	cp -fa $(TOOLS_HOST_DIR)/tools $(FREETZ_BASE_DIR)/
	touch $@

$(tool)-precompiled: $($(TOOL)_DIR)/.installed


$(tool)-clean:

$(tool)-dirclean:
	$(RM) -r $(TOOLS_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean $(patsubst %,%-distclean,$(filter-out $(TOOLS_BUILD_LOCAL),$(TOOLS)))

$(TOOL_FINISH)
