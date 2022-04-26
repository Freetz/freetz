$(call TOOL_INIT, 9a1d3b82435e09486a1c20acf44a1d2060ad7672)
# Versions after this commit have no vanilla GPL2
$(TOOL)_SOURCE:=yf-bootmanager-$($(TOOL)_VERSION).tar.xz
$(TOOL)_SOURCE_SHA256:=9bc13bbe05b0405fd730e5d9983bff17b97a8b2ad6ed8f4d1f3241ffb822edd7
$(TOOL)_SITE:=git_sparse@https://github.com/PeterPawn/YourFritz.git,bootmanager
### VERSION:=0.8.3
### WEBSITE:=https://github.com/PeterPawn/YourFritz/tree/main/bootmanager
### MANPAGE:=https://github.com/PeterPawn/YourFritz/tree/main/bootmanager#readme
### CHANGES:=https://github.com/PeterPawn/YourFritz/commits/main/bootmanager
### CVSREPO:=https://github.com/PeterPawn/YourFritz/tree/main/bootmanager


$(tool)-source: $(DL_DIR)/$($(TOOL)_SOURCE)
$(DL_DIR)/$($(TOOL)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(YF_BOOTMANAGER_HOST_SOURCE) $(YF_BOOTMANAGER_HOST_SITE) $(YF_BOOTMANAGER_HOST_SOURCE_SHA256)

$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(DL_DIR)/$($(TOOL)_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(YF_BOOTMANAGER_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(YF_BOOTMANAGER_HOST_MAKE_DIR)/patches,$(YF_BOOTMANAGER_HOST_DIR))
	touch $@

$($(TOOL)_DIR)/.installed: $($(TOOL)_DIR)/.unpacked
	mkdir -p $(TOOLS_DIR)/yf/
	tar cf - -C $(YF_BOOTMANAGER_HOST_DIR)/ bootmanager/ | tar xf - -C $(TOOLS_DIR)/yf/
	touch $@

$(tool)-precompiled: $($(TOOL)_DIR)/.installed


$(tool)-clean:

$(tool)-dirclean:
	$(RM) -r $(YF_BOOTMANAGER_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean
	$(RM) -r $(TOOLS_DIR)/yf/bootmanager/

$(TOOL_FINISH)
