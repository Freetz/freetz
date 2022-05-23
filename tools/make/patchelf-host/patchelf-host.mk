$(call TOOLS_INIT, 0.13.1)
# Versions since 0.14 require C++17 (eg Ubuntu 18)
$(PKG)_VERSION_LONG:=0.13.1.20211127.72b6d44
$(PKG)_SOURCE:=patchelf-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_SHA256:=39e8aeccd7495d54df094d2b4a7c08010ff7777036faaf24f28e07777d1598e2
$(PKG)_SITE:=https://github.com/NixOS/patchelf/releases/download/$($(PKG)_VERSION),https://releases.nixos.org/patchelf/patchelf-$($(PKG)_VERSION)
### WEBSITE:=https://opencollective.com/nixos
### MANPAGE:=https://sources.debian.org/patches/patchelf/
### CHANGES:=https://github.com/NixOS/patchelf/commits/master
### CVSREPO:=https://github.com/NixOS/patchelf

$(PKG)_DIR:=$(TOOLS_SOURCE_DIR)/$(pkg_short)-$($(PKG)_VERSION_LONG)


$(pkg)-source: $(DL_DIR)/$($(PKG)_SOURCE)
$(DL_DIR)/$($(PKG)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(PATCHELF_HOST_SOURCE) $(PATCHELF_HOST_SITE) $(PATCHELF_HOST_SOURCE_SHA256)

$(pkg)-unpacked: $($(PKG)_DIR)/.unpacked
$($(PKG)_DIR)/.unpacked: $(DL_DIR)/$($(PKG)_SOURCE) | $(TOOLS_SOURCE_DIR)
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xf $(DL_DIR)/$(PATCHELF_HOST_SOURCE)
	$(call APPLY_PATCHES,$(PATCHELF_HOST_MAKE_DIR)/patches,$(PATCHELF_HOST_DIR))
	touch $@

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked
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

$($(PKG)_DIR)/src/patchelf: $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(PATCHELF_HOST_DIR) all
	touch -c $@

$(TOOLS_DIR)/patchelf: $($(PKG)_DIR)/src/patchelf
	$(INSTALL_FILE)

$(pkg)-precompiled: $(TOOLS_DIR)/patchelf


$(pkg)-clean:
	-$(MAKE) -C $(PATCHELF_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(PATCHELF_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(TOOLS_DIR)/patchelf

$(TOOLS_FINISH)
