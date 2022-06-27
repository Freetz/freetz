$(call TOOLS_INIT, 24011d3735c6935f81792d017438be3bbf1a39d3)
$(PKG)_SOURCE:=yf-fit_tools-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=1aae6d570e937520f37e64c9226fc71771450318f8271465a7c73832306c77b6
$(PKG)_SITE:=git_sparse@https://github.com/PeterPawn/YourFritz.git,fit_tools
### VERSION:=0.2
### WEBSITE:=https://github.com/PeterPawn/YourFritz/tree/main/fit_tools
### MANPAGE:=https://github.com/PeterPawn/YourFritz/tree/main/fit_tools#readme
### CHANGES:=https://github.com/PeterPawn/YourFritz/commits/main/fit_tools
### CVSREPO:=https://github.com/PeterPawn/YourFritz/tree/main/fit_tools


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_NOP)

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.unpacked
	mkdir -p $(TOOLS_DIR)/yf/
	$(call COPY_USING_TAR,$(YF_FIT_TOOLS_HOST_DIR)/,$(TOOLS_DIR)/yf/,fit_tools/)
	touch $@

$(pkg)-precompiled: $($(PKG)_DIR)/.installed


$(pkg)-clean:

$(pkg)-dirclean:
	$(RM) -r $(YF_FIT_TOOLS_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r $(TOOLS_DIR)/yf/fit_tools/

$(TOOLS_FINISH)
