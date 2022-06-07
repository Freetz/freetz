$(call TOOLS_INIT, 2.5.1)
$(PKG)_SOURCE:=scons-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=0b25218ae7b46a967db42f2a53721645b3d42874a65f9552ad16ce26d30f51f2
$(PKG)_SITE:=@SF/scons

$(PKG)_TARGET_BINARY:=$(HOST_TOOLS_DIR)/usr/bin/scons

$(PKG)_DEPENDS:=python-host


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_NOP)

$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.unpacked
	$(abspath $(HOST_TOOLS_DIR)/usr/bin/python) \
		$(SCONS_HOST_DIR)/setup.py install \
		--prefix=$(abspath $(HOST_TOOLS_DIR)/usr) \
		--symlink-scons \
		--no-install-man \
		$(SILENT)
	find $(dir $@) -maxdepth 1 -type f -name "scons*" -exec $(SED) -i -r -e 's,^#![ ]*/usr/bin/env[ ]*python,#!$(abspath $(HOST_TOOLS_DIR)/usr/bin/python),g' \{\} \+

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	$(RM) -r $(SCONS_HOST_DIR)/build

$(pkg)-dirclean:
	$(RM) -r $(SCONS_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r $(HOST_TOOLS_DIR)/usr/{bin,lib}/scons*

$(TOOLS_FINISH)
