$(call TOOL_INIT, 4.8)
$(TOOL)_SOURCE:=sed-$($(TOOL)_VERSION).tar.xz
$(TOOL)_SOURCE_SHA256:=f79b0cfea71b37a8eeec8490db6c5f7ae7719c35587f21edb0617f370eeff633
$(TOOL)_SITE:=@GNU/sed


$(tool)-source: $(DL_DIR)/$($(TOOL)_SOURCE)
$(DL_DIR)/$($(TOOL)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(SED_HOST_SOURCE) $(SED_HOST_SITE) $(SED_HOST_SOURCE_SHA256)

$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(DL_DIR)/$($(TOOL)_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(SED_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(SED_HOST_MAKE_DIR)/patches,$(SED_HOST_DIR))
	touch $@

$($(TOOL)_DIR)/.configured: $($(TOOL)_DIR)/.unpacked
	(cd $(SED_HOST_DIR); $(RM) config.cache; \
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

$($(TOOL)_DIR)/sed/sed: $($(TOOL)_DIR)/.configured
	$(TOOL_SUBMAKE) -C $(SED_HOST_DIR) all
	touch -c $@

$(TOOLS_DIR)/sed: $($(TOOL)_DIR)/sed/sed
	$(INSTALL_FILE)

$(tool)-precompiled: $(TOOLS_DIR)/sed


$(tool)-clean:
	-$(MAKE) -C $(SED_HOST_DIR) clean

$(tool)-dirclean:
	$(RM) -r $(SED_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean
	$(RM) $(TOOLS_DIR)/sed

$(TOOL_FINISH)
