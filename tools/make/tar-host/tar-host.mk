$(call TOOLS_INIT, 1.34)
$(PKG)_SOURCE:=tar-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=63bebd26879c5e1eea4352f0d03c991f966aeb3ddeb3c7445c902568d5411d28
$(PKG)_SITE:=@GNU/tar

$(PKG)_DEPENDS_ON:=kconfig-host

$(PKG)_CONFIGURE_OPTIONS += --prefix=/usr
$(PKG)_CONFIGURE_OPTIONS += --without-selinux
$(PKG)_CONFIGURE_OPTIONS += --disable-acl


define $(PKG)_CUSTOM_UNPACK
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xf $(DL_DIR)/$($(PKG)_SOURCE)
endef

$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_DIR)/src/tar: $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(TAR_HOST_DIR) all
	touch -c $@

$(TOOLS_DIR)/tar-gnu: $($(PKG)_DIR)/src/tar
	$(INSTALL_FILE)

$(pkg)-precompiled: $(TOOLS_DIR)/tar-gnu


$(pkg)-clean:
	-$(MAKE) -C $(TAR_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(TAR_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(TOOLS_DIR)/tar-gnu

$(TOOLS_FINISH)
