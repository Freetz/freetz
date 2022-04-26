$(call TOOL_INIT, 0.1.34)
$(TOOL)_SOURCE:=mklibs_$($(TOOL)_VERSION).tar.gz
$(TOOL)_SOURCE_MD5:=afe0ed527ba96b8a882b5de350603007
$(TOOL)_SITE:=http://archive.debian.org/debian/pool/main/m/mklibs

$(TOOL)_DESTDIR:=$(FREETZ_BASE_DIR)/$(TOOLS_DIR)/build/bin
$(TOOL)_SCRIPT:=$($(TOOL)_DIR)/src/mklibs
$(TOOL)_TARGET_SCRIPT:=$($(TOOL)_DESTDIR)/mklibs
$(TOOL)_READELF_BINARY:=$($(TOOL)_DIR)/src/mklibs-readelf/mklibs-readelf
$(TOOL)_READELF_TARGET_BINARY:=$($(TOOL)_DESTDIR)/mklibs-readelf


$(tool)-source: $(DL_DIR)/$($(TOOL)_SOURCE)
$(DL_DIR)/$($(TOOL)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(MKLIBS_HOST_SOURCE) $(MKLIBS_HOST_SITE) $(MKLIBS_HOST_SOURCE_MD5)

$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(DL_DIR)/$($(TOOL)_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(MKLIBS_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(MKLIBS_HOST_MAKE_DIR)/patches,$(MKLIBS_HOST_DIR))
	touch $@

$($(TOOL)_SCRIPT): $($(TOOL)_DIR)/.unpacked

$($(TOOL)_DIR)/.configured: $($(TOOL)_DIR)/.unpacked
	(cd $(MKLIBS_HOST_DIR); $(RM) config.cache; \
		./configure \
		--prefix=/ \
		$(DISABLE_NLS) \
		$(SILENT) \
	);
	touch $@

$($(TOOL)_READELF_BINARY): $($(TOOL)_DIR)/.configured
	$(TOOL_SUBMAKE) CC="$(TOOLS_CC)" CXX="$(TOOLS_CXX)" CFLAGS="$(TOOLS_CFLAGS)" LDFLAGS="$(TOOLS_LDFLAGS)" -C $(MKLIBS_HOST_DIR) all

$($(TOOL)_TARGET_SCRIPT): $($(TOOL)_SCRIPT)
	$(INSTALL_FILE)

$($(TOOL)_READELF_TARGET_BINARY): $($(TOOL)_READELF_BINARY)
	$(INSTALL_FILE)

$(tool)-precompiled: $($(TOOL)_TARGET_SCRIPT) $($(TOOL)_READELF_TARGET_BINARY)


$(tool)-clean:
	-$(MAKE) -C $(MKLIBS_HOST_DIR) clean

$(tool)-dirclean:
	$(RM) -r $(MKLIBS_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean
	$(RM) -r $(MKLIBS_HOST_TARGET_SCRIPT) $(MKLIBS_HOST_READELF_TARGET_BINARY)

$(TOOL_FINISH)
