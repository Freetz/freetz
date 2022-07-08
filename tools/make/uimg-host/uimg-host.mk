$(call TOOLS_INIT, 871930df297e3a03bc315be75ecfc8c5c7a809ab)
$(PKG)_SOURCE:=uimg-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=1f5b3b473f50c6ff79a7859be336245c39fc1d2b6c89baf862de6de1f7caf8e0
$(PKG)_SITE:=git@https://bitbucket.org/fesc2000/uimg-tool.git
### WEBSITE:=https://bitbucket.org/fesc2000/uimg-tool/
### MANPAGE:=https://bitbucket.org/fesc2000/uimg-tool/src/master/README.md
### CHANGES:=https://bitbucket.org/fesc2000/uimg-tool/commits/
### CVSREPO:=https://bitbucket.org/fesc2000/uimg-tool/src/master/


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_NOP)

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
