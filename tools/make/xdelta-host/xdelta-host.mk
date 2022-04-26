$(call TOOL_INIT, 30q)
$(TOOL)_SOURCE:=xdelta$($(TOOL)_VERSION).tar.gz
$(TOOL)_SOURCE_MD5:=633717fb1b3fa77374dc1f3549cc7b59
$(TOOL)_SITE:=http://xdelta.googlecode.com/files

$(TOOL)_DIR:=$(TOOLS_SOURCE_DIR)/xdelta$($(TOOL)_VERSION)


$(tool)-source: $(DL_DIR)/$($(TOOL)_SOURCE)
$(DL_DIR)/$($(TOOL)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(XDELTA_HOST_SOURCE) $(XDELTA_HOST_SITE) $(XDELTA_HOST_SOURCE_MD5)

$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(DL_DIR)/$($(TOOL)_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(XDELTA_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(XDELTA_HOST_MAKE_DIR)/patches,$(XDELTA_HOST_DIR))
	touch $@

$($(TOOL)_DIR)/xdelta3: $($(TOOL)_DIR)/.unpacked
	$(TOOL_SUBMAKE) CC="$(TOOLS_CC)" CXX="$(TOOLS_CXX)" CFLAGS="$(TOOLS_CFLAGS)" LDFLAGS="$(TOOLS_LDFLAGS)" -C $(XDELTA_HOST_DIR) xdelta3

$(TOOLS_DIR)/xdelta3: $($(TOOL)_DIR)/xdelta3
	$(INSTALL_FILE)

$(tool)-precompiled: $(TOOLS_DIR)/xdelta3


$(tool)-clean:
	-$(MAKE) -C $(XDELTA_HOST_DIR) clean

$(tool)-dirclean:
	$(RM) -r $(XDELTA_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean
	$(RM) $(TOOLS_DIR)/xdelta3

$(TOOL_FINISH)
