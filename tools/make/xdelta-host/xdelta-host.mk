$(call TOOLS_INIT, 30q)
$(PKG)_SOURCE:=xdelta$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=633717fb1b3fa77374dc1f3549cc7b59
$(PKG)_SITE:=http://xdelta.googlecode.com/files

$(PKG)_DIR:=$(TOOLS_SOURCE_DIR)/xdelta$($(PKG)_VERSION)


$(pkg)-source: $(DL_DIR)/$($(PKG)_SOURCE)
$(DL_DIR)/$($(PKG)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(XDELTA_HOST_SOURCE) $(XDELTA_HOST_SITE) $(XDELTA_HOST_SOURCE_MD5)

$(pkg)-unpacked: $($(PKG)_DIR)/.unpacked
$($(PKG)_DIR)/.unpacked: $(DL_DIR)/$($(PKG)_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(XDELTA_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(XDELTA_HOST_MAKE_DIR)/patches,$(XDELTA_HOST_DIR))
	touch $@

$($(PKG)_DIR)/xdelta3: $($(PKG)_DIR)/.unpacked
	$(TOOLS_SUBMAKE) CC="$(TOOLS_CC)" CXX="$(TOOLS_CXX)" CFLAGS="$(TOOLS_CFLAGS)" LDFLAGS="$(TOOLS_LDFLAGS)" -C $(XDELTA_HOST_DIR) xdelta3

$(TOOLS_DIR)/xdelta3: $($(PKG)_DIR)/xdelta3
	$(INSTALL_FILE)

$(pkg)-precompiled: $(TOOLS_DIR)/xdelta3


$(pkg)-clean:
	-$(MAKE) -C $(XDELTA_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(XDELTA_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(TOOLS_DIR)/xdelta3

$(TOOLS_FINISH)
