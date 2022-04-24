E2FSPROGS_HOST_VERSION:=1.42.13
E2FSPROGS_HOST_SOURCE:=e2fsprogs-$(E2FSPROGS_HOST_VERSION).tar.xz
E2FSPROGS_HOST_SOURCE_MD5:=ce8e4821f5f53d4ebff4195038e38673
E2FSPROGS_HOST_SITE:=@SF/e2fsprogs,@KERNEL/linux/kernel/people/tytso/e2fsprogs/v$(E2FSPROGS_HOST_VERSION)

E2FSPROGS_HOST_DIR:=$(TOOLS_SOURCE_DIR)/e2fsprogs-$(E2FSPROGS_HOST_VERSION)
E2FSPROGS_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/e2fsprogs-host

E2FSPROGS_HOST_E2FSCK_BINARY:=$(E2FSPROGS_HOST_DIR)/e2fsck/e2fsck
E2FSPROGS_HOST_DEBUGFS_BINARY:=$(E2FSPROGS_HOST_DIR)/debugfs/debugfs
E2FSPROGS_HOST_TUNE2FS_BINARY:=$(E2FSPROGS_HOST_DIR)/misc/tune2fs


e2fsprogs-host-source: $(DL_DIR)/$(E2FSPROGS_HOST_SOURCE)
$(DL_DIR)/$(E2FSPROGS_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(E2FSPROGS_HOST_SOURCE) $(E2FSPROGS_HOST_SITE) $(E2FSPROGS_HOST_SOURCE_MD5)

e2fsprogs-host-unpacked: $(E2FSPROGS_HOST_DIR)/.unpacked
$(E2FSPROGS_HOST_DIR)/.unpacked: $(DL_DIR)/$(E2FSPROGS_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(E2FSPROGS_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(E2FSPROGS_HOST_MAKE_DIR)/patches,$(E2FSPROGS_HOST_DIR))
	touch $@

$(E2FSPROGS_HOST_DIR)/.configured: $(E2FSPROGS_HOST_DIR)/.unpacked
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

$(E2FSPROGS_HOST_DIR)/.compiled: $(E2FSPROGS_HOST_DIR)/.configured
	$(MAKE) -C $(E2FSPROGS_HOST_DIR) INFO=true all $(SILENT)
	touch $@

$(E2FSPROGS_HOST_E2FSCK_BINARY) $(E2FSPROGS_HOST_DEBUGFS_BINARY) $(E2FSPROGS_HOST_TUNE2FS_BINARY): $(E2FSPROGS_HOST_DIR)/.compiled

$(TOOLS_DIR)/e2fsck: $(E2FSPROGS_HOST_E2FSCK_BINARY)
	$(INSTALL_FILE)

$(TOOLS_DIR)/debugfs: $(E2FSPROGS_HOST_DEBUGFS_BINARY)
	$(INSTALL_FILE)

$(TOOLS_DIR)/tune2fs: $(E2FSPROGS_HOST_TUNE2FS_BINARY)
	$(INSTALL_FILE)

E2FSPROGS_HOST_DEVEL_ROOT:=$(abspath $(E2FSPROGS_HOST_DIR)/_devel)
e2fsprogs-host-devel: $(E2FSPROGS_HOST_DIR)/.devel
$(E2FSPROGS_HOST_DIR)/.devel: $(E2FSPROGS_HOST_DIR)/.compiled
	for i in blkid e2p et ext2fs quota ss uuid; do \
		$(MAKE) -C $(E2FSPROGS_HOST_DIR)/lib/$$i \
			DESTDIR=$(E2FSPROGS_HOST_DEVEL_ROOT) install; \
	done && \
	$(RM) -r $(E2FSPROGS_HOST_DEVEL_ROOT)/{bin,share} && \
	$(SED) -i -r -e 's,^(prefix=).*,\1$(E2FSPROGS_HOST_DEVEL_ROOT),' $(E2FSPROGS_HOST_DEVEL_ROOT)/lib/pkgconfig/*.pc && \
	touch $@

e2fsprogs-host-precompiled: $(TOOLS_DIR)/e2fsck $(TOOLS_DIR)/debugfs $(TOOLS_DIR)/tune2fs


e2fsprogs-host-clean:
	-$(MAKE) -C $(E2FSPROGS_HOST_DIR) clean
	$(RM) $(E2FSPROGS_HOST_DIR)/.compiled

e2fsprogs-host-dirclean:
	$(RM) -r $(E2FSPROGS_HOST_DIR)

e2fsprogs-host-distclean: e2fsprogs-host-dirclean
	$(RM) $(TOOLS_DIR)/e2fsck $(TOOLS_DIR)/debugfs $(TOOLS_DIR)/tune2fs

