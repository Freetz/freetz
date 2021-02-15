XDELTA_VERSION:=30q
XDELTA_SOURCE:=xdelta$(XDELTA_VERSION).tar.gz
XDELTA_SOURCE_MD5:=633717fb1b3fa77374dc1f3549cc7b59
XDELTA_SITE:=http://xdelta.googlecode.com/files
XDELTA_DIR:=$(TOOLS_SOURCE_DIR)/xdelta$(XDELTA_VERSION)

xdelta-source: $(DL_DIR)/$(XDELTA_SOURCE)
$(DL_DIR)/$(XDELTA_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(XDELTA_SOURCE) $(XDELTA_SITE) $(XDELTA_SOURCE_MD5)

xdelta-unpacked: $(XDELTA_DIR)/.unpacked
$(XDELTA_DIR)/.unpacked: $(DL_DIR)/$(XDELTA_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(XDELTA_SOURCE),$(TOOLS_SOURCE_DIR))
	touch $@

$(XDELTA_DIR)/xdelta3: $(XDELTA_DIR)/.unpacked
	$(MAKE) CC="$(TOOLS_CC)" -C $(XDELTA_DIR) xdelta3

$(TOOLS_DIR)/xdelta3: $(XDELTA_DIR)/xdelta3
	$(INSTALL_FILE)

xdelta: $(TOOLS_DIR)/xdelta3

xdelta-clean:
	-$(MAKE) -C $(XDELTA_DIR) clean

xdelta-dirclean:
	$(RM) -r $(XDELTA_DIR)

xdelta-distclean: xdelta-dirclean
	$(RM) $(TOOLS_DIR)/xdelta3
