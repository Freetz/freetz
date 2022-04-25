XDELTA_HOST_VERSION:=30q
XDELTA_HOST_SOURCE:=xdelta$(XDELTA_HOST_VERSION).tar.gz
XDELTA_HOST_SOURCE_MD5:=633717fb1b3fa77374dc1f3549cc7b59
XDELTA_HOST_SITE:=http://xdelta.googlecode.com/files
XDELTA_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/xdelta-host
XDELTA_HOST_DIR:=$(TOOLS_SOURCE_DIR)/xdelta$(XDELTA_HOST_VERSION)


xdelta-host-source: $(DL_DIR)/$(XDELTA_HOST_SOURCE)
$(DL_DIR)/$(XDELTA_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(XDELTA_HOST_SOURCE) $(XDELTA_HOST_SITE) $(XDELTA_HOST_SOURCE_MD5)

xdelta-host-unpacked: $(XDELTA_HOST_DIR)/.unpacked
$(XDELTA_HOST_DIR)/.unpacked: $(DL_DIR)/$(XDELTA_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(XDELTA_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(XDELTA_HOST_MAKE_DIR)/patches,$(XDELTA_HOST_DIR))
	touch $@

$(XDELTA_HOST_DIR)/xdelta3: $(XDELTA_HOST_DIR)/.unpacked
	$(TOOL_SUBMAKE) CC="$(TOOLS_CC)" CXX="$(TOOLS_CXX)" CFLAGS="$(TOOLS_CFLAGS)" LDFLAGS="$(TOOLS_LDFLAGS)" -C $(XDELTA_HOST_DIR) xdelta3

$(TOOLS_DIR)/xdelta3: $(XDELTA_HOST_DIR)/xdelta3
	$(INSTALL_FILE)

xdelta-host-precompiled: $(TOOLS_DIR)/xdelta3


xdelta-host-clean:
	-$(MAKE) -C $(XDELTA_HOST_DIR) clean

xdelta-host-dirclean:
	$(RM) -r $(XDELTA_HOST_DIR)

xdelta-host-distclean: xdelta-host-dirclean
	$(RM) $(TOOLS_DIR)/xdelta3

