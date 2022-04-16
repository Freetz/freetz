YF_JUISCHECK_HOST_VERSION:=049839bdf5811ed0c7d9b3036249c12a294ecffe
YF_JUISCHECK_HOST_SOURCE:=yf-juischeck-$(YF_JUISCHECK_HOST_VERSION).tar.xz
YF_JUISCHECK_HOST_SOURCE_SHA256:=35cbadc6eba5271163a2dab02f10bc0b7150590647031d816bb2f8d614f69c61
YF_JUISCHECK_HOST_SITE:=git_sparse@https://github.com/PeterPawn/YourFritz.git,juis
### VERSION:=0.5
### WEBSITE:=https://github.com/PeterPawn/YourFritz/tree/main/juis
### MANPAGE:=https://github.com/PeterPawn/YourFritz/tree/main/juis#readme
### CHANGES:=https://github.com/PeterPawn/YourFritz/commits/main/juis
### CVSREPO:=https://github.com/PeterPawn/YourFritz/tree/main/juis

YF_JUISCHECK_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/yf-juischeck-host
YF_JUISCHECK_HOST_DIR:=$(TOOLS_SOURCE_DIR)/yf-juischeck-$(YF_JUISCHECK_HOST_VERSION)


yf-juischeck-host-source: $(DL_DIR)/$(YF_JUISCHECK_HOST_SOURCE)
$(DL_DIR)/$(YF_JUISCHECK_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(YF_JUISCHECK_HOST_SOURCE) $(YF_JUISCHECK_HOST_SITE) $(YF_JUISCHECK_HOST_SOURCE_SHA256)

yf-juischeck-host-unpacked: $(YF_JUISCHECK_HOST_DIR)/.unpacked
$(YF_JUISCHECK_HOST_DIR)/.unpacked: $(DL_DIR)/$(YF_JUISCHECK_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(YF_JUISCHECK_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(YF_JUISCHECK_HOST_MAKE_DIR)/patches,$(YF_JUISCHECK_HOST_DIR))
	touch $@

$(YF_JUISCHECK_HOST_DIR)/.installed: $(YF_JUISCHECK_HOST_DIR)/.unpacked
	mkdir -p $(TOOLS_DIR)/yf/juischeck/
	tar cf - -C $(YF_JUISCHECK_HOST_DIR)/ juis/ | tar xf - -C $(TOOLS_DIR)/yf/
	touch $@

yf-juischeck-host-precompiled: $(YF_JUISCHECK_HOST_DIR)/.installed


yf-juischeck-host-clean:

yf-juischeck-host-dirclean:
	$(RM) -r $(YF_JUISCHECK_HOST_DIR)

yf-juischeck-host-distclean: yf-juischeck-host-dirclean
	$(RM) -rf $(TOOLS_DIR)/yf/juischeck/

