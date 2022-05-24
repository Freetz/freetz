$(call TOOLS_INIT, 871930df297e3a03bc315be75ecfc8c5c7a809ab)
$(PKG)_SOURCE:=uimg-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_SHA256:=1f5b3b473f50c6ff79a7859be336245c39fc1d2b6c89baf862de6de1f7caf8e0
$(PKG)_SITE:=git@https://bitbucket.org/fesc2000/uimg-tool.git


$(pkg)-source: $(DL_DIR)/$($(PKG)_SOURCE)
$(DL_DIR)/$($(PKG)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(UIMG_HOST_SOURCE) $(UIMG_HOST_SITE) $(UIMG_HOST_SOURCE_SHA256)

$(TOOLS_UNPACKED)

$($(PKG)_DIR)/uimg: $($(PKG)_DIR)/.unpacked
	$(TOOLS_SUBMAKE) CC="$(TOOLS_CC)" CXX="$(TOOLS_CXX)" CFLAGS="$(TOOLS_CFLAGS)" LDFLAGS="$(TOOLS_LDFLAGS)" -C $(UIMG_HOST_DIR) all
	touch -c $@

$(TOOLS_DIR)/uimg: $($(PKG)_DIR)/uimg
	$(INSTALL_FILE)

$(pkg)-precompiled: $(TOOLS_DIR)/uimg


$(pkg)-clean:
	-$(MAKE) -C $(UIMG_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(UIMG_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(TOOLS_DIR)/uimg

$(TOOLS_FINISH)
