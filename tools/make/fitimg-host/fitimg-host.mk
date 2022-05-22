$(call TOOL_INIT, 0.8)
$(TOOL)_SOURCE:=fitimg-$($(TOOL)_VERSION).tar.gz
$(TOOL)_SOURCE_SHA256:=55d42cdb7870f4525d37936741b9d3e61464319396747b26c1e5a0e1aee881d2
$(TOOL)_SITE:=https://boxmatrix.info/hosted/hippie2000
### WEBSITE:=https://boxmatrix.info/wiki/FIT-Image
### MANPAGE:=https://boxmatrix.info/wiki/FIT-Image#Usage
### CHANGES:=https://boxmatrix.info/wiki/FIT-Image#History


$(tool)-source: $(DL_DIR)/$($(TOOL)_SOURCE)
$(DL_DIR)/$($(TOOL)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(FITIMG_HOST_SOURCE) $(FITIMG_HOST_SITE) $(FITIMG_HOST_SOURCE_SHA256)

$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(DL_DIR)/$($(TOOL)_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(FITIMG_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(FITIMG_HOST_MAKE_DIR)/patches,$(FITIMG_HOST_DIR))
	touch $@

$($(TOOL)_DIR)/fitimg: $($(TOOL)_DIR)/.unpacked

$(TOOLS_DIR)/fitimg: $($(TOOL)_DIR)/fitimg
	$(INSTALL_FILE)

$(tool)-precompiled: $(TOOLS_DIR)/fitimg


$(tool)-clean:

$(tool)-dirclean:
	$(RM) -r $(FITIMG_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean
	$(RM) $(TOOLS_DIR)/fitimg

$(TOOL_FINISH)
