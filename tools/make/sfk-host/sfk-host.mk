$(call TOOLS_INIT, 1.9.7)
$(PKG)_SOURCE:=sfk-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=99225c1ab3fe87af6c275724ab635ae0
$(PKG)_SITE:=@SF/swissfileknife


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked
	(cd $(SFK_HOST_DIR); $(RM) config.cache; \
		CC="$(TOOLS_CC)" \
		CXX="$(TOOLS_CXX)" \
		CFLAGS="$(TOOLS_CFLAGS)" \
		LDFLAGS="$(TOOLS_LDFLAGS)" \
		./configure \
		--prefix=$(FREETZ_BASE_DIR)/$(TOOLS_DIR) \
		$(DISABLE_NLS) \
		$(SILENT) \
	);
	touch $@

$($(PKG)_DIR)/sfk: $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(SFK_HOST_DIR) all

$(TOOLS_DIR)/sfk: $($(PKG)_DIR)/sfk
	$(INSTALL_FILE)

$(pkg)-precompiled: $(TOOLS_DIR)/sfk


$(pkg)-clean:
	-$(MAKE) -C $(SFK_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(SFK_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(TOOLS_DIR)/sfk

$(TOOLS_FINISH)
