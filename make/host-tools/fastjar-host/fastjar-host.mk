$(call TOOLS_INIT, 0.98)
$(PKG)_SOURCE:=fastjar-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=f156abc5de8658f22ee8f08d7a72c88f9409ebd8c7933e9466b0842afeb2f145
$(PKG)_SITE:=https://download.savannah.nongnu.org/releases/fastjar
### WEBSITE:=https://savannah.nongnu.org/projects/fastjar
### CHANGES:=https://download.savannah.nongnu.org/releases/fastjar/
### CVSREPO:=https://cvs.savannah.nongnu.org/viewvc/fastjar/fastjar/

$(PKG)_BINARY:=$($(PKG)_DIR)/fastjar
$(PKG)_TARGET_BINARY:=$(TOOLS_DIR)/fastjar


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(FASTJAR_HOST_DIR) all

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(MAKE) -C $(FASTJAR_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(FASTJAR_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(FASTJAR_TARGET_BINARY)

$(TOOLS_FINISH)
