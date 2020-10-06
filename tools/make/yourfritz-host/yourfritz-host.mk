YOURFRITZ_HOST_VERSION:=ed5d2ab931
YOURFRITZ_HOST_SOURCE:=yourfritz-$(YOURFRITZ_HOST_VERSION).tar.xz
YOURFRITZ_HOST_SITE:=git_no_submodules@https://github.com/PeterPawn/YourFritz.git

YOURFRITZ_HOST_BASH_AS_SHEBANG += signimage/avm_pubkey_to_pkcs8
YOURFRITZ_HOST_BASH_AS_SHEBANG += signimage/check_signed_image
YOURFRITZ_HOST_BASH_AS_SHEBANG += signimage/generate_signing_key
YOURFRITZ_HOST_BASH_AS_SHEBANG += signimage/sign_image

YOURFRITZ_HOST_BASH_AS_SHEBANG += bootmanager/add_change_oem.sh
YOURFRITZ_HOST_BASH_AS_SHEBANG += bootmanager/add_to_system_reboot.sh

YOURFRITZ_HOST_BASH_AS_SHEBANG += eva_tools/eva_discover
YOURFRITZ_HOST_BASH_AS_SHEBANG += eva_tools/eva_get_environment
YOURFRITZ_HOST_BASH_AS_SHEBANG += eva_tools/eva_store_tffs
YOURFRITZ_HOST_BASH_AS_SHEBANG += eva_tools/eva_switch_system
YOURFRITZ_HOST_BASH_AS_SHEBANG += eva_tools/eva_to_memory
YOURFRITZ_HOST_BASH_AS_SHEBANG += eva_tools/image2ram

YOURFRITZ_HOST_BASH_AS_SHEBANG += avm_kernel_config/unpack_kernel.sh

YOURFRITZ_HOST_STRIP_TRAILING_WHITESPACES += bootmanager/gui_bootmanager

YOURFRITZ_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/yourfritz-host
YOURFRITZ_HOST_DIR:=$(TOOLS_SOURCE_DIR)/yourfritz-$(YOURFRITZ_HOST_VERSION)

yourfritz-host-source: $(DL_DIR)/$(YOURFRITZ_HOST_SOURCE)
$(DL_DIR)/$(YOURFRITZ_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(YOURFRITZ_HOST_SOURCE) $(YOURFRITZ_HOST_SITE) $(YOURFRITZ_HOST_SOURCE_MD5)

yourfritz-host-unpacked: $(YOURFRITZ_HOST_DIR)/.unpacked
$(YOURFRITZ_HOST_DIR)/.unpacked: $(DL_DIR)/$(YOURFRITZ_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(YOURFRITZ_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(YOURFRITZ_HOST_MAKE_DIR)/patches,$(YOURFRITZ_HOST_DIR))
	@$(SED) -i -r -e '1 s,^($(_hash)$(_bang)[ \t]*/bin/)(sh),\1ba\2,' $(YOURFRITZ_HOST_BASH_AS_SHEBANG:%=$(YOURFRITZ_HOST_DIR)/%)
	@$(SED) -i -r -e 's,([ \t])+$(_dollar),,' $(YOURFRITZ_HOST_STRIP_TRAILING_WHITESPACES:%=$(YOURFRITZ_HOST_DIR)/%)
	touch $@

$(YOURFRITZ_HOST_DIR)/.symlinked: | $(YOURFRITZ_HOST_DIR)/.unpacked
	@ln -Tsf ../$(YOURFRITZ_HOST_DIR:$(FREETZ_BASE_DIR)/%=%) $(TOOLS_DIR)/yf
	touch $@

yourfritz-host: $(YOURFRITZ_HOST_DIR)/.symlinked

yourfritz-host-clean:

yourfritz-host-dirclean:
	$(RM) -r $(YOURFRITZ_HOST_DIR)

yourfritz-host-distclean: yourfritz-host-dirclean
	$(RM) $(TOOLS_DIR)/yf
