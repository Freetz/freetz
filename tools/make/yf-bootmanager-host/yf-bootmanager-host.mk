YF_BOOTMANAGER_HOST_VERSION:=9a1d3b82435e09486a1c20acf44a1d2060ad7672
# Versions after this commit have no vanilla GPL2
YF_BOOTMANAGER_HOST_SOURCE:=yf-bootmanager-$(YF_BOOTMANAGER_HOST_VERSION).tar.xz
YF_BOOTMANAGER_HOST_SOURCE_SHA256:=9bc13bbe05b0405fd730e5d9983bff17b97a8b2ad6ed8f4d1f3241ffb822edd7
YF_BOOTMANAGER_HOST_SITE:=git_sparse@https://github.com/PeterPawn/YourFritz.git,bootmanager
### VERSION:=0.8.3
### WEBSITE:=https://github.com/PeterPawn/YourFritz/tree/main/bootmanager
### MANPAGE:=https://github.com/PeterPawn/YourFritz/tree/main/bootmanager#readme
### CHANGES:=https://github.com/PeterPawn/YourFritz/commits/main/bootmanager
### CVSREPO:=https://github.com/PeterPawn/YourFritz/tree/main/bootmanager

YF_BOOTMANAGER_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/yf-bootmanager-host
YF_BOOTMANAGER_HOST_DIR:=$(TOOLS_SOURCE_DIR)/yf-bootmanager-$(YF_BOOTMANAGER_HOST_VERSION)


yf-bootmanager-host-source: $(DL_DIR)/$(YF_BOOTMANAGER_HOST_SOURCE)
$(DL_DIR)/$(YF_BOOTMANAGER_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(YF_BOOTMANAGER_HOST_SOURCE) $(YF_BOOTMANAGER_HOST_SITE) $(YF_BOOTMANAGER_HOST_SOURCE_SHA256)

yf-bootmanager-host-unpacked: $(YF_BOOTMANAGER_HOST_DIR)/.unpacked
$(YF_BOOTMANAGER_HOST_DIR)/.unpacked: $(DL_DIR)/$(YF_BOOTMANAGER_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(YF_BOOTMANAGER_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(YF_BOOTMANAGER_HOST_MAKE_DIR)/patches,$(YF_BOOTMANAGER_HOST_DIR))
	touch $@

$(YF_BOOTMANAGER_HOST_DIR)/.installed: $(YF_BOOTMANAGER_HOST_DIR)/.unpacked
	mkdir -p $(TOOLS_DIR)/yf/
	tar cf - -C $(YF_BOOTMANAGER_HOST_DIR)/ bootmanager/ | tar xf - -C $(TOOLS_DIR)/yf/
	touch $@

yf-bootmanager-host-precompiled: $(YF_BOOTMANAGER_HOST_DIR)/.installed


yf-bootmanager-host-clean:

yf-bootmanager-host-dirclean:
	$(RM) -r $(YF_BOOTMANAGER_HOST_DIR)

yf-bootmanager-host-distclean: yf-bootmanager-host-dirclean
	$(RM) -r $(TOOLS_DIR)/yf/bootmanager/

