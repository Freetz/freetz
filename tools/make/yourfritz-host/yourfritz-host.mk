YOURFRITZ_HOST_VERSION:=5e3342106f241f9378cb295fcccd41350a394ff6
YOURFRITZ_HOST_SOURCE:=yourfritz-$(YOURFRITZ_HOST_VERSION).tar.xz
YOURFRITZ_HOST_SOURCE_SHA256:=3e8b6ffda738443e2cd296bee686a5b672d8470ffec41f1014ca885b0115a519
YOURFRITZ_HOST_SITE:=git_no_submodules@https://github.com/PeterPawn/YourFritz.git
### WEBSITE:=https://github.com/PeterPawn/YourFritz
### MANPAGE:=https://github.com/PeterPawn/YourFritz#readme
### CHANGES:=https://github.com/PeterPawn/YourFritz/tags
### CVSREPO:=https://github.com/PeterPawn/YourFritz/commits/main

YOURFRITZ_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/yourfritz-host
YOURFRITZ_HOST_DIR:=$(TOOLS_SOURCE_DIR)/yourfritz-$(YOURFRITZ_HOST_VERSION)

YOURFRITZ_HOST_BASH_AS_SHEBANG += avm_kernel_config/unpack_kernel.sh


yourfritz-host-source: $(DL_DIR)/$(YOURFRITZ_HOST_SOURCE)
$(DL_DIR)/$(YOURFRITZ_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(YOURFRITZ_HOST_SOURCE) $(YOURFRITZ_HOST_SITE) $(YOURFRITZ_HOST_SOURCE_SHA256)

yourfritz-host-unpacked: $(YOURFRITZ_HOST_DIR)/.unpacked
$(YOURFRITZ_HOST_DIR)/.unpacked: $(DL_DIR)/$(YOURFRITZ_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(YOURFRITZ_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(YOURFRITZ_HOST_MAKE_DIR)/patches,$(YOURFRITZ_HOST_DIR))
	@$(SED) -i -r -e '1 s,^($(_hash)$(_bang)[ \t]*/bin/)(sh),\1ba\2,' $(YOURFRITZ_HOST_BASH_AS_SHEBANG:%=$(YOURFRITZ_HOST_DIR)/%)
	touch $@

$(YOURFRITZ_HOST_DIR)/.symlinked: | $(YOURFRITZ_HOST_DIR)/.unpacked
	@ln -Tsf ../$(YOURFRITZ_HOST_DIR:$(FREETZ_BASE_DIR)/%=%) $(TOOLS_DIR)/yf
	touch $@

yourfritz-host-precompiled: $(YOURFRITZ_HOST_DIR)/.symlinked


yourfritz-host-clean:

yourfritz-host-dirclean:
	$(RM) -r $(YOURFRITZ_HOST_DIR)

yourfritz-host-distclean: yourfritz-host-dirclean
	$(RM) $(TOOLS_DIR)/yf

