$(call TOOL_INIT, 0.13.1)
# Versions since 0.14 require C++17 (eg Ubuntu 18)
$(TOOL)_VERSION_LONG:=0.13.1.20211127.72b6d44
$(TOOL)_SOURCE:=patchelf-$($(TOOL)_VERSION).tar.bz2
$(TOOL)_SOURCE_SHA256:=39e8aeccd7495d54df094d2b4a7c08010ff7777036faaf24f28e07777d1598e2
$(TOOL)_SITE:=https://github.com/NixOS/patchelf/releases/download/$($(TOOL)_VERSION),https://releases.nixos.org/patchelf/patchelf-$($(TOOL)_VERSION)
### WEBSITE:=https://opencollective.com/nixos
### MANPAGE:=https://sources.debian.org/patches/patchelf/
### CHANGES:=https://github.com/NixOS/patchelf/commits/master
### CVSREPO:=https://github.com/NixOS/patchelf

$(TOOL)_DIR:=$(TOOLS_SOURCE_DIR)/$(tool_short)-$($(TOOL)_VERSION_LONG)


$(tool)-source: $(DL_DIR)/$($(TOOL)_SOURCE)
$(DL_DIR)/$($(TOOL)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(PATCHELF_HOST_SOURCE) $(PATCHELF_HOST_SITE) $(PATCHELF_HOST_SOURCE_SHA256)

$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(DL_DIR)/$($(TOOL)_SOURCE) | $(TOOLS_SOURCE_DIR)
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xf $(DL_DIR)/$(PATCHELF_HOST_SOURCE)
	$(call APPLY_PATCHES,$(PATCHELF_HOST_MAKE_DIR)/patches,$(PATCHELF_HOST_DIR))
	touch $@

$($(TOOL)_DIR)/.configured: $($(TOOL)_DIR)/.unpacked
	(cd $(PATCHELF_HOST_DIR); $(RM) config.cache; \
		CC="$(TOOLS_CC)" \
		CXX="$(TOOLS_CXX)" \
		CFLAGS="$(TOOLS_CFLAGS)" \
		LDFLAGS="$(TOOLS_LDFLAGS)" \
		./configure \
		--prefix=/usr \
		$(QUIET) \
	);
	touch $@

$($(TOOL)_DIR)/src/patchelf: $($(TOOL)_DIR)/.configured
	$(TOOL_SUBMAKE) -C $(PATCHELF_HOST_DIR) all
	touch -c $@

$(TOOLS_DIR)/patchelf: $($(TOOL)_DIR)/src/patchelf
	$(INSTALL_FILE)

$(tool)-precompiled: $(TOOLS_DIR)/patchelf


$(tool)-clean:
	-$(MAKE) -C $(PATCHELF_HOST_DIR) clean

$(tool)-dirclean:
	$(RM) -r $(PATCHELF_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean
	$(RM) $(TOOLS_DIR)/patchelf

$(TOOL_FINISH)
