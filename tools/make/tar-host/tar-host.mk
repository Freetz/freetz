$(call TOOLS_INIT, 1.34)
$(PKG)_SOURCE:=tar-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_MD5:=9a08d29a9ac4727130b5708347c0f5cf
$(PKG)_SITE:=@GNU/tar

$(PKG)_DEPENDS_ON:=

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
