YF_JUIS_HOST_VERSION:=049839bdf5811ed0c7d9b3036249c12a294ecffe
YF_JUIS_HOST_SOURCE:=yf-juis-$(YF_JUIS_HOST_VERSION).tar.xz
YF_JUIS_HOST_SOURCE_SHA256:=9ba42eb23e1e71a6c235e37b2090a8ffba1d5103536f68a8ecf7dc94af816241
YF_JUIS_HOST_SITE:=git_sparse@https://github.com/PeterPawn/YourFritz.git,juis
### VERSION:=0.5
### WEBSITE:=https://github.com/PeterPawn/YourFritz/tree/main/juis
### MANPAGE:=https://github.com/PeterPawn/YourFritz/tree/main/juis#readme
### CHANGES:=https://github.com/PeterPawn/YourFritz/commits/main/juis
### CVSREPO:=https://github.com/PeterPawn/YourFritz/tree/main/juis

YF_JUIS_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/yf-juis-host
YF_JUIS_HOST_DIR:=$(TOOLS_SOURCE_DIR)/yf-juis-$(YF_JUIS_HOST_VERSION)


yf-juis-host-source: $(DL_DIR)/$(YF_JUIS_HOST_SOURCE)
$(DL_DIR)/$(YF_JUIS_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(YF_JUIS_HOST_SOURCE) $(YF_JUIS_HOST_SITE) $(YF_JUIS_HOST_SOURCE_SHA256)

yf-juis-host-unpacked: $(YF_JUIS_HOST_DIR)/.unpacked
$(YF_JUIS_HOST_DIR)/.unpacked: $(DL_DIR)/$(YF_JUIS_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(YF_JUIS_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(YF_JUIS_HOST_MAKE_DIR)/patches,$(YF_JUIS_HOST_DIR))
	touch $@

$(YF_JUIS_HOST_DIR)/.installed: $(YF_JUIS_HOST_DIR)/.unpacked
	mkdir -p $(TOOLS_DIR)/yf/
	tar cf - -C $(YF_JUIS_HOST_DIR)/ juis/ | tar xf - -C $(TOOLS_DIR)/yf/
	touch $@

yf-juis-host-precompiled: $(YF_JUIS_HOST_DIR)/.installed


yf-juis-host-clean:

yf-juis-host-dirclean:
	$(RM) -r $(YF_JUIS_HOST_DIR)

yf-juis-host-distclean: yf-juis-host-dirclean
	$(RM) -rf $(TOOLS_DIR)/yf/juis/

