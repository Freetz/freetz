$(call TOOLS_INIT, 2.5.1)
$(PKG)_SOURCE:=scons-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=aaaf09e1351a598f98d17b0cf1103e7a
$(PKG)_SITE:=@SF/scons

$(PKG)_DEPENDS:=python-host


$(pkg)-source: $(DL_DIR)/$($(PKG)_SOURCE)
$(DL_DIR)/$($(PKG)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(SCONS_HOST_SOURCE) $(SCONS_HOST_SITE) $(SCONS_HOST_SOURCE_MD5)

$(pkg)-unpacked: $($(PKG)_DIR)/.unpacked
$($(PKG)_DIR)/.unpacked: $(DL_DIR)/$($(PKG)_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(SCONS_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(SCONS_HOST_MAKE_DIR)/patches,$(SCONS_HOST_DIR))
	touch $@

$(HOST_TOOLS_DIR)/usr/bin/scons: $($(PKG)_DIR)/.unpacked | $($(PKG)_DEPENDS)
	$(abspath $(HOST_TOOLS_DIR)/usr/bin/python) \
		$(SCONS_HOST_DIR)/setup.py install \
		--prefix=$(abspath $(HOST_TOOLS_DIR)/usr) \
		--symlink-scons \
		--no-install-man \
		$(SILENT)
	find $(dir $@) -maxdepth 1 -type f -name "scons*" -exec $(SED) -i -r -e 's,^#![ ]*/usr/bin/env[ ]*python,#!$(abspath $(HOST_TOOLS_DIR)/usr/bin/python),g' \{\} \+

$(pkg)-precompiled: $(HOST_TOOLS_DIR)/usr/bin/scons


$(pkg)-clean:
	$(RM) -r $(SCONS_HOST_DIR)/build

$(pkg)-dirclean:
	$(RM) -r $(SCONS_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r $(HOST_TOOLS_DIR)/usr/{bin,lib}/scons*

$(TOOLS_FINISH)
