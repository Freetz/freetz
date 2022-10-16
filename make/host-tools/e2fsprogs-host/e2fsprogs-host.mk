$(call TOOLS_INIT, 1.42.13)
$(PKG)_SOURCE:=e2fsprogs-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=e16474b5a3a30f9197160c4b91bd48d5a463583049c0fcc405b6f0f7075aa0c7
$(PKG)_SITE:=@SF/e2fsprogs,@KERNEL/linux/kernel/people/tytso/e2fsprogs/v$($(PKG)_VERSION)

$(PKG)_E2FSCK_BINARY:=$($(PKG)_DIR)/e2fsck/e2fsck
$(PKG)_DEBUGFS_BINARY:=$($(PKG)_DIR)/debugfs/debugfs
$(PKG)_TUNE2FS_BINARY:=$($(PKG)_DIR)/misc/tune2fs

$(PKG)_CONFIGURE_OPTIONS += --prefix=/
$(PKG)_CONFIGURE_OPTIONS += --disable-bsd-shlibs
$(PKG)_CONFIGURE_OPTIONS += --disable-elf-shlibs
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --without-libpth-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libintl-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PKG)_CONFIGURE_OPTIONS += --disable-backtrace
$(PKG)_CONFIGURE_OPTIONS += --disable-blkid-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-compression
$(PKG)_CONFIGURE_OPTIONS += --enable-debugfs
$(PKG)_CONFIGURE_OPTIONS += --disable-defrag
$(PKG)_CONFIGURE_OPTIONS += --disable-e2initrd-helper
$(PKG)_CONFIGURE_OPTIONS += --disable-fsck
$(PKG)_CONFIGURE_OPTIONS += --disable-htree
$(PKG)_CONFIGURE_OPTIONS += --disable-imager
$(PKG)_CONFIGURE_OPTIONS += --disable-jbd-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-profile
$(PKG)_CONFIGURE_OPTIONS += --disable-quota
$(PKG)_CONFIGURE_OPTIONS += --disable-resizer
$(PKG)_CONFIGURE_OPTIONS += --disable-testio-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-uuidd
$(PKG)_CONFIGURE_OPTIONS += --disable-threads
$(PKG)_CONFIGURE_OPTIONS += --disable-tls


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

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
