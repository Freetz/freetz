$(call TOOL_INIT, 871930df297e3a03bc315be75ecfc8c5c7a809ab)
$(TOOL)_SOURCE:=uimg-$($(TOOL)_VERSION).tar.xz
$(TOOL)_SOURCE_SHA256:=1f5b3b473f50c6ff79a7859be336245c39fc1d2b6c89baf862de6de1f7caf8e0
$(TOOL)_SITE:=git@https://bitbucket.org/fesc2000/uimg-tool.git


$(tool)-source: $(DL_DIR)/$($(TOOL)_SOURCE)
$(DL_DIR)/$($(TOOL)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(UIMG_HOST_SOURCE) $(UIMG_HOST_SITE) $(UIMG_HOST_SOURCE_SHA256)

$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(DL_DIR)/$($(TOOL)_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(UIMG_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(UIMG_HOST_MAKE_DIR)/patches,$(UIMG_HOST_DIR))
	touch $@

$($(TOOL)_DIR)/uimg: $($(TOOL)_DIR)/.unpacked
	$(TOOL_SUBMAKE) CC="$(TOOLS_CC)" CXX="$(TOOLS_CXX)" CFLAGS="$(TOOLS_CFLAGS)" LDFLAGS="$(TOOLS_LDFLAGS)" -C $(UIMG_HOST_DIR) all
	touch -c $@

$(TOOLS_DIR)/uimg: $($(TOOL)_DIR)/uimg
	$(INSTALL_FILE)

$(tool)-precompiled: $(TOOLS_DIR)/uimg


$(tool)-clean:
	-$(MAKE) -C $(UIMG_HOST_DIR) clean

$(tool)-dirclean:
	$(RM) -r $(UIMG_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean
	$(RM) $(TOOLS_DIR)/uimg

$(TOOL_FINISH)
