$(call TOOLS_INIT, 1.42.13)
$(PKG)_SOURCE:=e2fsprogs-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_MD5:=ce8e4821f5f53d4ebff4195038e38673
$(PKG)_SITE:=@SF/e2fsprogs,@KERNEL/linux/kernel/people/tytso/e2fsprogs/v$($(PKG)_VERSION)

$(PKG)_E2FSCK_BINARY:=$($(PKG)_DIR)/e2fsck/e2fsck
$(PKG)_DEBUGFS_BINARY:=$($(PKG)_DIR)/debugfs/debugfs
$(PKG)_TUNE2FS_BINARY:=$($(PKG)_DIR)/misc/tune2fs


$(pkg)-source: $(DL_DIR)/$($(PKG)_SOURCE)
$(DL_DIR)/$($(PKG)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(E2FSPROGS_HOST_SOURCE) $(E2FSPROGS_HOST_SITE) $(E2FSPROGS_HOST_SOURCE_MD5)

$(pkg)-unpacked: $($(PKG)_DIR)/.unpacked
$($(PKG)_DIR)/.unpacked: $(DL_DIR)/$($(PKG)_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(E2FSPROGS_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(E2FSPROGS_HOST_MAKE_DIR)/patches,$(E2FSPROGS_HOST_DIR))
	touch $@

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked
	(cd $(E2FSPROGS_HOST_DIR); $(RM) config.cache; \
		CC="$(TOOLS_CC)" \
		CXX="$(TOOLS_CXX)" \
		CFLAGS="$(TOOLS_CFLAGS)" \
		LDFLAGS="$(TOOLS_LDFLAGS)" \
		./configure \
		--prefix=/ \
		--disable-bsd-shlibs \
		--disable-elf-shlibs \
		--disable-rpath \
		--without-libpth-prefix \
		--without-libintl-prefix \
		--without-libiconv-prefix \
		--disable-backtrace \
		--disable-blkid-debug \
		--disable-compression \
		--enable-debugfs \
		--disable-defrag \
		--disable-e2initrd-helper \
		--disable-fsck \
		--disable-htree \
		--disable-imager \
		--disable-jbd-debug \
		--disable-profile \
		--disable-quota \
		--disable-resizer \
		--disable-testio-debug \
		--disable-uuidd \
		--disable-threads \
		--disable-tls \
		$(DISABLE_NLS) \
		$(SILENT) \
	);
	touch $@

$($(PKG)_DIR)/.compiled: $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(E2FSPROGS_HOST_DIR) INFO=true all
	touch $@

$($(PKG)_E2FSCK_BINARY) $($(PKG)_DEBUGFS_BINARY) $($(PKG)_TUNE2FS_BINARY): $($(PKG)_DIR)/.compiled

$(TOOLS_DIR)/e2fsck: $($(PKG)_E2FSCK_BINARY)
	$(INSTALL_FILE)

$(TOOLS_DIR)/debugfs: $($(PKG)_DEBUGFS_BINARY)
	$(INSTALL_FILE)

$(TOOLS_DIR)/tune2fs: $($(PKG)_TUNE2FS_BINARY)
	$(INSTALL_FILE)

$(PKG)_DEVEL_ROOT:=$(abspath $($(PKG)_DIR)/_devel)
$(pkg)-devel: $($(PKG)_DIR)/.devel
$($(PKG)_DIR)/.devel: $($(PKG)_DIR)/.compiled
	for i in blkid e2p et ext2fs quota ss uuid; do \
		$(TOOLS_SUBMAKE) -C $(E2FSPROGS_HOST_DIR)/lib/$$i \
			DESTDIR=$(E2FSPROGS_HOST_DEVEL_ROOT) install; \
	done && \
	$(RM) -r $(E2FSPROGS_HOST_DEVEL_ROOT)/{bin,share} && \
	$(SED) -i -r -e 's,^(prefix=).*,\1$(E2FSPROGS_HOST_DEVEL_ROOT),' $(E2FSPROGS_HOST_DEVEL_ROOT)/lib/pkgconfig/*.pc && \
	touch $@

$(pkg)-precompiled: $(TOOLS_DIR)/e2fsck $(TOOLS_DIR)/debugfs $(TOOLS_DIR)/tune2fs


$(pkg)-clean:
	-$(MAKE) -C $(E2FSPROGS_HOST_DIR) clean
	$(RM) $(E2FSPROGS_HOST_DIR)/.compiled

$(pkg)-dirclean:
	$(RM) -r $(E2FSPROGS_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(TOOLS_DIR)/e2fsck $(TOOLS_DIR)/debugfs $(TOOLS_DIR)/tune2fs

$(TOOLS_FINISH)
