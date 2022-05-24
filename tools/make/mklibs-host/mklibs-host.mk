$(call TOOLS_INIT, 0.1.34)
$(PKG)_SOURCE:=mklibs_$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=afe0ed527ba96b8a882b5de350603007
$(PKG)_SITE:=http://archive.debian.org/debian/pool/main/m/mklibs

$(PKG)_DESTDIR:=$(FREETZ_BASE_DIR)/$(TOOLS_DIR)/build/bin
$(PKG)_SCRIPT:=$($(PKG)_DIR)/src/mklibs
$(PKG)_TARGET_SCRIPT:=$($(PKG)_DESTDIR)/mklibs
$(PKG)_READELF_BINARY:=$($(PKG)_DIR)/src/mklibs-readelf/mklibs-readelf
$(PKG)_READELF_TARGET_BINARY:=$($(PKG)_DESTDIR)/mklibs-readelf


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)

$($(PKG)_SCRIPT): $($(PKG)_DIR)/.unpacked

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked
	(cd $(MKLIBS_HOST_DIR); $(RM) config.cache; \
		./configure \
		--prefix=/ \
		$(DISABLE_NLS) \
		$(SILENT) \
	);
	touch $@

$($(PKG)_READELF_BINARY): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) CC="$(TOOLS_CC)" CXX="$(TOOLS_CXX)" CFLAGS="$(TOOLS_CFLAGS)" LDFLAGS="$(TOOLS_LDFLAGS)" -C $(MKLIBS_HOST_DIR) all

$($(PKG)_TARGET_SCRIPT): $($(PKG)_SCRIPT)
	$(INSTALL_FILE)

$($(PKG)_READELF_TARGET_BINARY): $($(PKG)_READELF_BINARY)
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_TARGET_SCRIPT) $($(PKG)_READELF_TARGET_BINARY)


$(pkg)-clean:
	-$(MAKE) -C $(MKLIBS_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(MKLIBS_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r $(MKLIBS_HOST_TARGET_SCRIPT) $(MKLIBS_HOST_READELF_TARGET_BINARY)

$(TOOLS_FINISH)
