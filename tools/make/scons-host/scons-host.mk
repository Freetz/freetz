SCONS_HOST_VERSION:=2.5.1
SCONS_HOST_SOURCE:=scons-$(SCONS_HOST_VERSION).tar.gz
SCONS_HOST_SOURCE_MD5:=aaaf09e1351a598f98d17b0cf1103e7a
SCONS_HOST_SITE:=@SF/scons

SCONS_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/scons-host
SCONS_HOST_DIR:=$(TOOLS_SOURCE_DIR)/scons-$(SCONS_HOST_VERSION)

SCONS_HOST:=$(HOST_TOOLS_DIR)/usr/bin/scons


scons-host-source: $(DL_DIR)/$(SCONS_HOST_SOURCE)
$(DL_DIR)/$(SCONS_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(SCONS_HOST_SOURCE) $(SCONS_HOST_SITE) $(SCONS_HOST_SOURCE_MD5)

scons-host-unpacked: $(SCONS_HOST_DIR)/.unpacked
$(SCONS_HOST_DIR)/.unpacked: $(DL_DIR)/$(SCONS_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(SCONS_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(SCONS_HOST_MAKE_DIR)/patches,$(SCONS_HOST_DIR))
	touch $@

$(SCONS_HOST): $(SCONS_HOST_DIR)/.unpacked | python-host
	$(abspath $(HOST_TOOLS_DIR)/usr/bin/python) \
		$(SCONS_HOST_DIR)/setup.py install \
		--prefix=$(abspath $(HOST_TOOLS_DIR)/usr) \
		--symlink-scons \
		--no-install-man \
		$(SILENT)
	find $(dir $@) -maxdepth 1 -type f -name "scons*" -exec $(SED) -i -r -e 's,^#![ ]*/usr/bin/env[ ]*python,#!$(abspath $(HOST_TOOLS_DIR)/usr/bin/python),g' \{\} \+

scons-host-precompiled: $(SCONS_HOST)


scons-host-clean:
	$(RM) -r $(SCONS_HOST_DIR)/build

scons-host-dirclean:
	$(RM) -r $(SCONS_HOST_DIR)

scons-host-distclean: scons-host-dirclean
	$(RM) -r $(HOST_TOOLS_DIR)/usr/{bin,lib}/scons*

