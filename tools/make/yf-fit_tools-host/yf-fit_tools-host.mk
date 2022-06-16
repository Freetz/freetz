$(call TOOLS_INIT, 21e6d8692d91cdaf01f755550232e6e74ae06299)
$(PKG)_SOURCE:=yf-fit_tools-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=155e66119f4d6a84448087e1237bc4553fd9cfbef9924b30eb4a9c4919387712
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
