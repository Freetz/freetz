$(call TOOLS_INIT, 0.1.34)
$(PKG)_SOURCE:=mklibs_$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=0c13c314f5c397529f58a5a02d57d83aeb4463d6a0d80b9374c6576ec37ed39f
$(PKG)_SITE:=http://archive.debian.org/debian/pool/main/m/mklibs
### WEBSITE:=https://packages.debian.org/sid/mklibs
### MANPAGE:=https://manpages.debian.org/unstable/mklibs/mklibs.1.html
### CHANGES:=https://salsa.debian.org/installer-team/mklibs/blob/master/debian/changelog
### CVSREPO:=https://github.com/openwrt/openwrt/tree/master/tools/mklibs

$(PKG)_DESTDIR:=$(FREETZ_BASE_DIR)/$(TOOLS_DIR)/build/bin
$(PKG)_SCRIPT:=$($(PKG)_DIR)/src/mklibs
$(PKG)_TARGET_SCRIPT:=$($(PKG)_DESTDIR)/mklibs
$(PKG)_READELF_BINARY:=$($(PKG)_DIR)/src/mklibs-readelf/mklibs-readelf
$(PKG)_READELF_TARGET_BINARY:=$($(PKG)_DESTDIR)/mklibs-readelf

$(PKG)_CONFIGURE_OPTIONS += --prefix=/


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_SCRIPT): $($(PKG)_DIR)/.unpacked

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
