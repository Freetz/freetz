$(call TOOLS_INIT, 0.8)
$(PKG)_SOURCE:=fitimg-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=55d42cdb7870f4525d37936741b9d3e61464319396747b26c1e5a0e1aee881d2
$(PKG)_SITE:=https://boxmatrix.info/hosted/hippie2000
### WEBSITE:=https://boxmatrix.info/wiki/FIT-Image
### MANPAGE:=https://boxmatrix.info/wiki/FIT-Image#Usage
### CHANGES:=https://boxmatrix.info/wiki/FIT-Image#History


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_NOP)

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
