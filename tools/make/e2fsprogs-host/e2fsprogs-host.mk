$(call TOOL_INIT, 1.42.13)
$(TOOL)_SOURCE:=e2fsprogs-$($(TOOL)_VERSION).tar.xz
$(TOOL)_SOURCE_MD5:=ce8e4821f5f53d4ebff4195038e38673
$(TOOL)_SITE:=@SF/e2fsprogs,@KERNEL/linux/kernel/people/tytso/e2fsprogs/v$($(TOOL)_VERSION)

$(TOOL)_E2FSCK_BINARY:=$($(TOOL)_DIR)/e2fsck/e2fsck
$(TOOL)_DEBUGFS_BINARY:=$($(TOOL)_DIR)/debugfs/debugfs
$(TOOL)_TUNE2FS_BINARY:=$($(TOOL)_DIR)/misc/tune2fs


$(tool)-source: $(DL_DIR)/$($(TOOL)_SOURCE)
$(DL_DIR)/$($(TOOL)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(E2FSPROGS_HOST_SOURCE) $(E2FSPROGS_HOST_SITE) $(E2FSPROGS_HOST_SOURCE_MD5)

$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(DL_DIR)/$($(TOOL)_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(E2FSPROGS_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(E2FSPROGS_HOST_MAKE_DIR)/patches,$(E2FSPROGS_HOST_DIR))
	touch $@

$($(TOOL)_DIR)/.configured: $($(TOOL)_DIR)/.unpacked
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

$($(TOOL)_DIR)/.compiled: $($(TOOL)_DIR)/.configured
	$(TOOL_SUBMAKE) -C $(E2FSPROGS_HOST_DIR) INFO=true all
	touch $@

$($(TOOL)_E2FSCK_BINARY) $($(TOOL)_DEBUGFS_BINARY) $($(TOOL)_TUNE2FS_BINARY): $($(TOOL)_DIR)/.compiled

$(TOOLS_DIR)/e2fsck: $($(TOOL)_E2FSCK_BINARY)
	$(INSTALL_FILE)

$(TOOLS_DIR)/debugfs: $($(TOOL)_DEBUGFS_BINARY)
	$(INSTALL_FILE)

$(TOOLS_DIR)/tune2fs: $($(TOOL)_TUNE2FS_BINARY)
	$(INSTALL_FILE)

$(TOOL)_DEVEL_ROOT:=$(abspath $($(TOOL)_DIR)/_devel)
$(tool)-devel: $($(TOOL)_DIR)/.devel
$($(TOOL)_DIR)/.devel: $($(TOOL)_DIR)/.compiled
	for i in blkid e2p et ext2fs quota ss uuid; do \
		$(TOOL_SUBMAKE) -C $(E2FSPROGS_HOST_DIR)/lib/$$i \
			DESTDIR=$(E2FSPROGS_HOST_DEVEL_ROOT) install; \
	done && \
	$(RM) -r $(E2FSPROGS_HOST_DEVEL_ROOT)/{bin,share} && \
	$(SED) -i -r -e 's,^(prefix=).*,\1$(E2FSPROGS_HOST_DEVEL_ROOT),' $(E2FSPROGS_HOST_DEVEL_ROOT)/lib/pkgconfig/*.pc && \
	touch $@

$(tool)-precompiled: $(TOOLS_DIR)/e2fsck $(TOOLS_DIR)/debugfs $(TOOLS_DIR)/tune2fs


$(tool)-clean:
	-$(MAKE) -C $(E2FSPROGS_HOST_DIR) clean
	$(RM) $(E2FSPROGS_HOST_DIR)/.compiled

$(tool)-dirclean:
	$(RM) -r $(E2FSPROGS_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean
	$(RM) $(TOOLS_DIR)/e2fsck $(TOOLS_DIR)/debugfs $(TOOLS_DIR)/tune2fs

$(TOOL_FINISH)
