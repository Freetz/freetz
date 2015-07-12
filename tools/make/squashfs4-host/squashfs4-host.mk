SQUASHFS4_HOST_VERSION:=4.3
SQUASHFS4_HOST_SOURCE:=squashfs$(SQUASHFS4_HOST_VERSION).tar.gz
SQUASHFS4_HOST_SOURCE_MD5:=d92ab59aabf5173f2a59089531e30dbf
SQUASHFS4_HOST_SITE:=@SF/squashfs

SQUASHFS4_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/squashfs4-host
SQUASHFS4_HOST_DIR:=$(TOOLS_SOURCE_DIR)/squashfs$(SQUASHFS4_HOST_VERSION)

SQUASHFS4_HOST_unsquashfs_BUILD_DIR:=$(SQUASHFS4_HOST_DIR)/squashfs-tools
SQUASHFS4_HOST_unsquashfs:=$(SQUASHFS4_HOST_unsquashfs_BUILD_DIR)/unsquashfs
SQUASHFS4_HOST_unsquashfs_TARGET:=$(TOOLS_DIR)/unsquashfs4-lzma

SQUASHFS4_HOST_mksquashfs_BUILD_DIR:=$(SQUASHFS4_HOST_DIR)/squashfs-tools-mksquashfs-avm-be
SQUASHFS4_HOST_mksquashfs:=$(SQUASHFS4_HOST_mksquashfs_BUILD_DIR)/mksquashfs
SQUASHFS4_HOST_mksquashfs_TARGET:=$(TOOLS_DIR)/mksquashfs4-lzma-avm-be

squashfs4-host-source: $(DL_DIR)/$(SQUASHFS4_HOST_SOURCE)
$(DL_DIR)/$(SQUASHFS4_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(SQUASHFS4_HOST_SOURCE) $(SQUASHFS4_HOST_SITE) $(SQUASHFS4_HOST_SOURCE_MD5)

squashfs4-host-unpacked: $(SQUASHFS4_HOST_DIR)/.unpacked
$(SQUASHFS4_HOST_DIR)/.unpacked: $(DL_DIR)/$(SQUASHFS4_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(SQUASHFS4_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	# unsquashfs only build dir
	$(call APPLY_PATCHES,$(SQUASHFS4_HOST_MAKE_DIR)/patches,$(SQUASHFS4_HOST_DIR))
	# mksquashfs only build dir
	(cd $(SQUASHFS4_HOST_DIR); cp -a squashfs-tools $(notdir $(SQUASHFS4_HOST_mksquashfs_BUILD_DIR)))
	$(call APPLY_PATCHES,$(SQUASHFS4_HOST_MAKE_DIR)/patches/mksquashfs-avm-be,$(SQUASHFS4_HOST_DIR))
	touch $@

SQUASHFS4_HOST_COMMON_MAKE_OPTS += CC="$(TOOLS_CC)"
SQUASHFS4_HOST_COMMON_MAKE_OPTS += XZ_SUPPORT=1
SQUASHFS4_HOST_COMMON_MAKE_OPTS +=  XZ_DIR="$(abspath $(LZMA2_DIR))"
SQUASHFS4_HOST_COMMON_MAKE_OPTS += GZIP_SUPPORT=1
SQUASHFS4_HOST_COMMON_MAKE_OPTS += COMP_DEFAULT=xz

$(SQUASHFS4_HOST_unsquashfs): $(SQUASHFS4_HOST_DIR)/.unpacked $(LZMA2_DIR)/liblzma.a
	$(MAKE) -C $(SQUASHFS4_HOST_unsquashfs_BUILD_DIR) \
		$(SQUASHFS4_HOST_COMMON_MAKE_OPTS) \
		unsquashfs
	touch -c $@

$(SQUASHFS4_HOST_unsquashfs_TARGET): $(SQUASHFS4_HOST_unsquashfs)
	$(INSTALL_FILE)
	strip $@

$(SQUASHFS4_HOST_mksquashfs): $(SQUASHFS4_HOST_DIR)/.unpacked $(LZMA2_DIR)/liblzma.a
	$(MAKE) -C $(SQUASHFS4_HOST_mksquashfs_BUILD_DIR) \
		$(SQUASHFS4_HOST_COMMON_MAKE_OPTS) \
		mksquashfs
	touch -c $@

$(SQUASHFS4_HOST_mksquashfs_TARGET): $(SQUASHFS4_HOST_mksquashfs)
	$(INSTALL_FILE)
	strip $@

squashfs4-host: $(SQUASHFS4_HOST_unsquashfs_TARGET) $(SQUASHFS4_HOST_mksquashfs_TARGET)

squashfs4-host-clean:
	-$(MAKE) -C $(SQUASHFS4_HOST_unsquashfs_BUILD_DIR) clean
	-$(MAKE) -C $(SQUASHFS4_HOST_mksquashfs_BUILD_DIR) clean

squashfs4-host-dirclean:
	$(RM) -r $(SQUASHFS4_HOST_DIR)

squashfs4-host-distclean: squashfs4-host-dirclean
	$(RM) $(SQUASHFS4_HOST_unsquashfs_TARGET) $(SQUASHFS4_HOST_mksquashfs_TARGET)
