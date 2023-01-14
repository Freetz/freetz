$(call TOOLS_INIT, 0.17.2)
$(PKG)_SOURCE:=patchelf-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=bae2ea376072e422c196218dd9bdef0548ccc08da4de9f36b4672df84ea2d8e2
$(PKG)_SITE:=https://github.com/NixOS/patchelf/releases/download/$($(PKG)_VERSION),https://releases.nixos.org/patchelf/patchelf-$($(PKG)_VERSION)
### WEBSITE:=https://opencollective.com/nixos
### MANPAGE:=https://sources.debian.org/patches/patchelf/
### CHANGES:=https://github.com/NixOS/patchelf/commits/master
### CVSREPO:=https://github.com/NixOS/patchelf

$(PKG)_CONFIGURE_OPTIONS += --prefix=/usr


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

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
