$(call TOOL_INIT, 1.34)
$(TOOL)_SOURCE:=tar-$($(TOOL)_VERSION).tar.xz
$(TOOL)_SOURCE_MD5:=9a08d29a9ac4727130b5708347c0f5cf
$(TOOL)_SITE:=@GNU/tar


$(tool)-source: $(DL_DIR)/$($(TOOL)_SOURCE)
$(DL_DIR)/$($(TOOL)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(TAR_HOST_SOURCE) $(TAR_HOST_SITE) $(TAR_HOST_SOURCE_MD5)

$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(DL_DIR)/$($(TOOL)_SOURCE) | $(TOOLS_SOURCE_DIR)
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xf $(DL_DIR)/$(TAR_HOST_SOURCE)
	$(call APPLY_PATCHES,$(TAR_HOST_MAKE_DIR)/patches,$(TAR_HOST_DIR))
	touch $@

$($(TOOL)_DIR)/.configured: $($(TOOL)_DIR)/.unpacked
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

$($(TOOL)_DIR)/src/tar: $($(TOOL)_DIR)/.configured
	$(TOOL_SUBMAKE) -C $(TAR_HOST_DIR) all
	touch -c $@

$(TOOLS_DIR)/tar-gnu: $($(TOOL)_DIR)/src/tar
	$(INSTALL_FILE)

$(tool)-precompiled: $(TOOLS_DIR)/tar-gnu


$(tool)-clean:
	-$(MAKE) -C $(TAR_HOST_DIR) clean

$(tool)-dirclean:
	$(RM) -r $(TAR_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean
	$(RM) $(TOOLS_DIR)/tar-gnu

$(TOOL_FINISH)
