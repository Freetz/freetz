YF_SIGNIMAGE_HOST_VERSION:=78a5689449c95f589ff426286ffd9c99614c66cc
YF_SIGNIMAGE_HOST_SOURCE:=yf-signimage-$(YF_SIGNIMAGE_HOST_VERSION).tar.xz
YF_SIGNIMAGE_HOST_SOURCE_SHA256:=69ad98d89848b55832385e27a8ce091a12e9ee0b41733faf2d5d7d0dfcbc4aff
YF_SIGNIMAGE_HOST_SITE:=git_sparse@https://github.com/PeterPawn/YourFritz.git,signimage
### VERSION:=1.0.1
### WEBSITE:=https://github.com/PeterPawn/YourFritz/tree/main/signimage
### MANPAGE:=https://github.com/PeterPawn/YourFritz/tree/main/signimage#readme
### CHANGES:=https://github.com/PeterPawn/YourFritz/commits/main/signimage
### CVSREPO:=https://github.com/PeterPawn/YourFritz/tree/main/signimage

YF_SIGNIMAGE_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/yf-signimage-host
YF_SIGNIMAGE_HOST_DIR:=$(TOOLS_SOURCE_DIR)/yf-signimage-$(YF_SIGNIMAGE_HOST_VERSION)


yf-signimage-host-source: $(DL_DIR)/$(YF_SIGNIMAGE_HOST_SOURCE)
$(DL_DIR)/$(YF_SIGNIMAGE_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(YF_SIGNIMAGE_HOST_SOURCE) $(YF_SIGNIMAGE_HOST_SITE) $(YF_SIGNIMAGE_HOST_SOURCE_SHA256)

yf-signimage-host-unpacked: $(YF_SIGNIMAGE_HOST_DIR)/.unpacked
$(YF_SIGNIMAGE_HOST_DIR)/.unpacked: $(DL_DIR)/$(YF_SIGNIMAGE_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(YF_SIGNIMAGE_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(YF_SIGNIMAGE_HOST_MAKE_DIR)/patches,$(YF_SIGNIMAGE_HOST_DIR))
	touch $@

$(YF_SIGNIMAGE_HOST_DIR)/.installed: $(YF_SIGNIMAGE_HOST_DIR)/.unpacked
	mkdir -p $(TOOLS_DIR)/yf/signimage/
	tar cf - -C $(YF_SIGNIMAGE_HOST_DIR)/ signimage/ | tar xf - -C $(TOOLS_DIR)/yf/
	touch $@

yf-signimage-host-precompiled: $(YF_SIGNIMAGE_HOST_DIR)/.installed


yf-signimage-host-clean:

yf-signimage-host-dirclean:
	$(RM) -r $(YF_SIGNIMAGE_HOST_DIR)

yf-signimage-host-distclean: yf-signimage-host-dirclean
	$(RM) -rf $(TOOLS_DIR)/yf/signimage/

