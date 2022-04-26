$(call TOOL_INIT, 2.5.1)
$(TOOL)_SOURCE:=scons-$($(TOOL)_VERSION).tar.gz
$(TOOL)_SOURCE_MD5:=aaaf09e1351a598f98d17b0cf1103e7a
$(TOOL)_SITE:=@SF/scons

$(TOOL)_DEPENDS:=python-host


$(tool)-source: $(DL_DIR)/$($(TOOL)_SOURCE)
$(DL_DIR)/$($(TOOL)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(SCONS_HOST_SOURCE) $(SCONS_HOST_SITE) $(SCONS_HOST_SOURCE_MD5)

$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(DL_DIR)/$($(TOOL)_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(SCONS_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(SCONS_HOST_MAKE_DIR)/patches,$(SCONS_HOST_DIR))
	touch $@

$(HOST_TOOLS_DIR)/usr/bin/scons: $($(TOOL)_DIR)/.unpacked | $($(TOOL)_DEPENDS)
	$(abspath $(HOST_TOOLS_DIR)/usr/bin/python) \
		$(SCONS_HOST_DIR)/setup.py install \
		--prefix=$(abspath $(HOST_TOOLS_DIR)/usr) \
		--symlink-scons \
		--no-install-man \
		$(SILENT)
	find $(dir $@) -maxdepth 1 -type f -name "scons*" -exec $(SED) -i -r -e 's,^#![ ]*/usr/bin/env[ ]*python,#!$(abspath $(HOST_TOOLS_DIR)/usr/bin/python),g' \{\} \+

$(tool)-precompiled: $(HOST_TOOLS_DIR)/usr/bin/scons


$(tool)-clean:
	$(RM) -r $(SCONS_HOST_DIR)/build

$(tool)-dirclean:
	$(RM) -r $(SCONS_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean
	$(RM) -r $(HOST_TOOLS_DIR)/usr/{bin,lib}/scons*

$(TOOL_FINISH)
