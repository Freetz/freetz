YF_BOOTMANAGER_HOST_REPOSITORY:=https://github.com/PeterPawn/YourFritz.git
YF_BOOTMANAGER_HOST_VERSION:=$(if $(FREETZ_PATCH_MODFS_BOOT_MANAGER__TESTTAG),$(call git-get-tag-revision,$(YF_BOOTMANAGER_HOST_REPOSITORY),freetz-ng-test),dd1e06670c455cb92728c01a4dc1eb464ed6df91)
YF_BOOTMANAGER_HOST_VERSION:=dd1e06670c455cb92728c01a4dc1eb464ed6df91
YF_BOOTMANAGER_HOST_SOURCE:=yf-bootmanager-$(YF_BOOTMANAGER_HOST_VERSION).tar.xz
YF_BOOTMANAGER_HOST_SOURCE_SHA256:=3d3b64c41bd2a7df8d81563c8c1be36bda88f906a917209b0554e59c0036df60
YF_BOOTMANAGER_HOST_SITE:=git_sparse@$(YF_BOOTMANAGER_HOST_REPOSITORY),bootmanager
### VERSION:=0.8.5
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
	mkdir -p $(TOOLS_DIR)/yf/bootmanager/
	tar cf - -C $(YF_BOOTMANAGER_HOST_DIR)/ bootmanager/ | tar xf - -C $(TOOLS_DIR)/yf/
	touch $@

yf-bootmanager-host-precompiled: $(YF_BOOTMANAGER_HOST_DIR)/.installed


yf-bootmanager-host-clean:

yf-bootmanager-host-dirclean:
	$(RM) -r $(YF_BOOTMANAGER_HOST_DIR)

yf-bootmanager-host-distclean: yf-bootmanager-host-dirclean
	$(RM) -rf $(TOOLS_DIR)/yf/bootmanager/

