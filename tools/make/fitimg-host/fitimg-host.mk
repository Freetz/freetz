$(call TOOLS_INIT, 0.8)
$(PKG)_SOURCE:=fitimg-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA256:=55d42cdb7870f4525d37936741b9d3e61464319396747b26c1e5a0e1aee881d2
$(PKG)_SITE:=https://boxmatrix.info/hosted/hippie2000
### WEBSITE:=https://boxmatrix.info/wiki/FIT-Image
### MANPAGE:=https://boxmatrix.info/wiki/FIT-Image#Usage
### CHANGES:=https://boxmatrix.info/wiki/FIT-Image#History


$(pkg)-source: $(DL_DIR)/$($(PKG)_SOURCE)
$(DL_DIR)/$($(PKG)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(FITIMG_HOST_SOURCE) $(FITIMG_HOST_SITE) $(FITIMG_HOST_SOURCE_SHA256)

$(pkg)-unpacked: $($(PKG)_DIR)/.unpacked
$($(PKG)_DIR)/.unpacked: $(DL_DIR)/$($(PKG)_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(FITIMG_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(FITIMG_HOST_MAKE_DIR)/patches,$(FITIMG_HOST_DIR))
	touch $@

$($(PKG)_DIR)/fitimg: $($(PKG)_DIR)/.unpacked

$(TOOLS_DIR)/fitimg: $($(PKG)_DIR)/fitimg
	$(INSTALL_FILE)

$(pkg)-precompiled: $(TOOLS_DIR)/fitimg


$(pkg)-clean:

$(pkg)-dirclean:
	$(RM) -r $(FITIMG_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(TOOLS_DIR)/fitimg

$(TOOLS_FINISH)
