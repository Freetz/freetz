$(call TOOLS_INIT, 9a1d3b82435e09486a1c20acf44a1d2060ad7672)
# Versions after this commit have no vanilla GPL2
$(PKG)_SOURCE:=yf-bootmanager-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_SHA256:=9bc13bbe05b0405fd730e5d9983bff17b97a8b2ad6ed8f4d1f3241ffb822edd7
$(PKG)_SITE:=git_sparse@https://github.com/PeterPawn/YourFritz.git,bootmanager
### VERSION:=0.8.3
### WEBSITE:=https://github.com/PeterPawn/YourFritz/tree/main/bootmanager
### MANPAGE:=https://github.com/PeterPawn/YourFritz/tree/main/bootmanager#readme
### CHANGES:=https://github.com/PeterPawn/YourFritz/commits/main/bootmanager
### CVSREPO:=https://github.com/PeterPawn/YourFritz/tree/main/bootmanager


$(pkg)-source: $(DL_DIR)/$($(PKG)_SOURCE)
$(DL_DIR)/$($(PKG)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(YF_BOOTMANAGER_HOST_SOURCE) $(YF_BOOTMANAGER_HOST_SITE) $(YF_BOOTMANAGER_HOST_SOURCE_SHA256)

$(pkg)-unpacked: $($(PKG)_DIR)/.unpacked
$($(PKG)_DIR)/.unpacked: $(DL_DIR)/$($(PKG)_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(YF_BOOTMANAGER_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(YF_BOOTMANAGER_HOST_MAKE_DIR)/patches,$(YF_BOOTMANAGER_HOST_DIR))
	touch $@

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.unpacked
	mkdir -p $(TOOLS_DIR)/yf/
	tar cf - -C $(YF_BOOTMANAGER_HOST_DIR)/ bootmanager/ | tar xf - -C $(TOOLS_DIR)/yf/
	touch $@

$(pkg)-precompiled: $($(PKG)_DIR)/.installed


$(pkg)-clean:

$(pkg)-dirclean:
	$(RM) -r $(YF_BOOTMANAGER_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r $(TOOLS_DIR)/yf/bootmanager/

$(TOOLS_FINISH)
