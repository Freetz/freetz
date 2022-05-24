$(call TOOLS_INIT, 1.34)
$(PKG)_SOURCE:=tar-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_MD5:=9a08d29a9ac4727130b5708347c0f5cf
$(PKG)_SITE:=@GNU/tar

$(PKG)_DEPENDS_ON:=


define $(PKG)_CUSTOM_UNPACK
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xf $(DL_DIR)/$(TAR_HOST_SOURCE)
endef

$(pkg)-source: $(DL_DIR)/$($(PKG)_SOURCE)
$(DL_DIR)/$($(PKG)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(TAR_HOST_SOURCE) $(TAR_HOST_SITE) $(TAR_HOST_SOURCE_MD5)

$(TOOLS_UNPACKED)

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked
	(cd $(TAR_HOST_DIR); $(RM) config.cache; \
		CC="$(TOOLS_CC)" \
		CXX="$(TOOLS_CXX)" \
		CFLAGS="$(TOOLS_CFLAGS)" \
		LDFLAGS="$(TOOLS_LDFLAGS)" \
		./configure \
		--prefix=/usr \
		--without-selinux \
		--disable-acl \
		$(DISABLE_NLS) \
		$(SILENT) \
	);
	touch $@

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
