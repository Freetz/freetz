YF_BOOTMANAGER_HOST_REPOSITORY:=https://github.com/PeterPawn/YourFritz.git
$(call TOOLS_INIT, $(if $(FREETZ_PATCH_MODFS_BOOT_MANAGER_labor),$(call git-get-tag-revision,$(YF_BOOTMANAGER_HOST_REPOSITORY),freetz-ng-test),$(if $(FREETZ_PATCH_MODFS_BOOT_MANAGER_latest),$(call git-get-tag-revision,$(YF_BOOTMANAGER_HOST_REPOSITORY),freetz-ng-version),87ee8c3b73edf4ba70025a017aa1d49cd2c66036)))
# Versions after this commit have no vanilla GPL3 - but it's not a problem to use the unchanged(!) version in an own image.
$(PKG)_SOURCE:=yf-bootmanager-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=f47e9395048d2d095f8d6a5286941adf9da837bb303b2366466365b2f984c1bb
$(PKG)_SITE:=git_sparse@$($(PKG)_REPOSITORY),bootmanager
### VERSION:=0.8.6
### WEBSITE:=https://github.com/PeterPawn/YourFritz/tree/main/bootmanager
### MANPAGE:=https://github.com/PeterPawn/YourFritz/tree/main/bootmanager#readme
### CHANGES:=https://github.com/PeterPawn/YourFritz/commits/main/bootmanager
### CVSREPO:=https://github.com/PeterPawn/YourFritz/tree/main/bootmanager

$(PKG)_REBUILD_SUBOPTS += FREETZ_PATCH_MODFS_BOOT_MANAGER_tested
$(PKG)_REBUILD_SUBOPTS += FREETZ_PATCH_MODFS_BOOT_MANAGER_latest
$(PKG)_REBUILD_SUBOPTS += FREETZ_PATCH_MODFS_BOOT_MANAGER_labor


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_NOP)

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.unpacked
	mkdir -p $(TOOLS_DIR)/yf/
	$(call COPY_USING_TAR,$(YF_BOOTMANAGER_HOST_DIR)/,$(TOOLS_DIR)/yf/,bootmanager/)
	touch $@

$(pkg)-precompiled: $($(PKG)_DIR)/.installed


$(pkg)-clean:

$(pkg)-dirclean:
	$(RM) -r $(YF_BOOTMANAGER_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r $(TOOLS_DIR)/yf/bootmanager/

$(TOOLS_FINISH)
