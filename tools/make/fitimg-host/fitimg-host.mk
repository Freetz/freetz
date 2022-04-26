$(call TOOL_INIT, 0.7.2)
$(TOOL)_SOURCE:=fitimg-$($(TOOL)_VERSION).tar.gz
$(TOOL)_SOURCE_SHA256:=d83503f31a763143f242269e4ee834609dd4c2bcb5809ccdf19b4f06adb6f2ab
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
