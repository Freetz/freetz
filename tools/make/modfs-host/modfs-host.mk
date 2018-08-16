MODFS_HOST_VERSION:=64b879d037
MODFS_HOST_SOURCE:=modfs-$(MODFS_HOST_VERSION).tar.xz
MODFS_HOST_SITE:=git_no_submodules@https://github.com/PeterPawn/modfs.git

MODFS_HOST_BASH_AS_SHEBANG += modfs
MODFS_HOST_STRIP_TRAILING_WHITESPACES += modscripts/gui_boot_manager_v0.4

MODFS_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/modfs-host
MODFS_HOST_DIR:=$(TOOLS_SOURCE_DIR)/modfs-$(MODFS_HOST_VERSION)

modfs-host-source: $(DL_DIR)/$(MODFS_HOST_SOURCE)
$(DL_DIR)/$(MODFS_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(MODFS_HOST_SOURCE) $(MODFS_HOST_SITE) $(MODFS_HOST_SOURCE_MD5)

modfs-host-unpacked: $(MODFS_HOST_DIR)/.unpacked
$(MODFS_HOST_DIR)/.unpacked: $(DL_DIR)/$(MODFS_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(MODFS_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(MODFS_HOST_MAKE_DIR)/patches,$(MODFS_HOST_DIR))
	@$(SED) -i -r -e '1 s,^($(_hash)$(_bang)[ \t]*/bin/)(sh),\1ba\2,' $(MODFS_HOST_BASH_AS_SHEBANG:%=$(MODFS_HOST_DIR)/%)
	@$(SED) -i -r -e 's,([ \t])+$(_dollar),,' $(MODFS_HOST_STRIP_TRAILING_WHITESPACES:%=$(MODFS_HOST_DIR)/%)
	touch $@

$(MODFS_HOST_DIR)/.symlinked: | $(MODFS_HOST_DIR)/.unpacked
	@ln -Tsf ../$(MODFS_HOST_DIR:$(FREETZ_BASE_DIR)/%=%) $(TOOLS_DIR)/modfs
	touch $@

modfs-host: $(MODFS_HOST_DIR)/.symlinked

modfs-host-clean:

modfs-host-dirclean:
	$(RM) -r $(MODFS_HOST_DIR)

modfs-host-distclean: modfs-host-dirclean
	$(RM) $(TOOLS_DIR)/modfs
