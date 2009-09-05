SQUASHFS_VERSION:=2.2-r2
SQUASHFS_SOURCE:=squashfs$(SQUASHFS_VERSION).tar.gz
SQUASHFS_SOURCE_MD5:=a8d09a217240127ae4d339e8368d2de1
SQUASHFS_SITE:=@SF/squashfs
SQUASHFS_DIR:=$(TOOLS_SOURCE_DIR)/squashfs$(SQUASHFS_VERSION)

MKSQUASHFS_DIR:=$(SQUASHFS_DIR)/squashfs-tools
MKSQUASHFS_MAKE_DIR:=$(TOOLS_DIR)/make

UNSQUASHFS_DIR:=$(SQUASHFS_DIR)/squashfs-tools
UNSQUASHFS_MAKE_DIR:=$(TOOLS_DIR)/make

SQUASHFS_LZMA_VERSION:=443
SQUASHFS_LZMA_DIR:=$(TOOLS_SOURCE_DIR)/lzma$(SQUASHFS_LZMA_VERSION)
SQUASHFS_EXTERNAL_LZMA_DIR:=../../lzma$(SQUASHFS_LZMA_VERSION)


$(DL_DIR)/$(SQUASHFS_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(TOOLS_DOT_CONFIG) $(SQUASHFS_SOURCE) $(SQUASHFS_SITE) $(SQUASHFS_SOURCE_MD5)

$(SQUASHFS_DIR)/.unpacked: $(DL_DIR)/$(SQUASHFS_SOURCE) | $(TOOLS_SOURCE_DIR)
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(SQUASHFS_SOURCE)
	for i in $(MKSQUASHFS_MAKE_DIR)/patches/*.squashfs.patch; do \
		$(PATCH_TOOL) $(SQUASHFS_DIR) $$i; \
	done
	touch $@

$(MKSQUASHFS_DIR)/mksquashfs: $(SQUASHFS_DIR)/.unpacked
	$(MAKE) CC="$(TOOLS_CC)" \
		-C $(MKSQUASHFS_DIR) mksquashfs
	touch -c $@

$(MKSQUASHFS_DIR)/mksquashfs-lzma: $(SQUASHFS_DIR)/.unpacked $(SQUASHFS_LZMA_DIR)/liblzma.a
	$(MAKE) CXX="$(TOOLS_CXX)" LZMA_DIR="$(SQUASHFS_EXTERNAL_LZMA_DIR)" \
		-C $(MKSQUASHFS_DIR) mksquashfs-lzma
	touch -c $@

$(UNSQUASHFS_DIR)/unsquashfs: $(SQUASHFS_DIR)/.unpacked
	$(MAKE) CC="$(TOOLS_CC)" \
		-C $(UNSQUASHFS_DIR) unsquashfs
	touch -c $@

$(UNSQUASHFS_DIR)/unsquashfs-lzma: $(SQUASHFS_DIR)/.unpacked $(SQUASHFS_LZMA_DIR)/liblzma.a
	$(MAKE) CXX="$(TOOLS_CXX)" LZMA_DIR="$(SQUASHFS_EXTERNAL_LZMA_DIR)" \
		-C $(MKSQUASHFS_DIR) unsquashfs-lzma
	touch -c $@

$(TOOLS_DIR)/mksquashfs: $(MKSQUASHFS_DIR)/mksquashfs
	cp $(MKSQUASHFS_DIR)/mksquashfs $(TOOLS_DIR)/mksquashfs

$(TOOLS_DIR)/mksquashfs-lzma: $(MKSQUASHFS_DIR)/mksquashfs-lzma
	cp $(MKSQUASHFS_DIR)/mksquashfs-lzma $(TOOLS_DIR)/mksquashfs-lzma

$(TOOLS_DIR)/unsquashfs: $(UNSQUASHFS_DIR)/unsquashfs
	cp $(UNSQUASHFS_DIR)/unsquashfs $(TOOLS_DIR)/unsquashfs

$(TOOLS_DIR)/unsquashfs-lzma: $(UNSQUASHFS_DIR)/unsquashfs-lzma
	cp $(UNSQUASHFS_DIR)/unsquashfs-lzma $(TOOLS_DIR)/unsquashfs-lzma

squashfs: $(TOOLS_DIR)/mksquashfs-lzma $(TOOLS_DIR)/unsquashfs-lzma

squashfs-source: $(SQUASHFS_DIR)/.unpacked

squashfs-clean:
	-$(MAKE) -C $(MKSQUASHFS_DIR) clean

squashfs-dirclean:
	$(RM) -r $(SQUASHFS_DIR)

squashfs-distclean: squashfs-dirclean
	$(RM) $(TOOLS_DIR)/mksquashfs
	$(RM) $(TOOLS_DIR)/mksquashfs-lzma
	$(RM) $(TOOLS_DIR)/unsquashfs
	$(RM) $(TOOLS_DIR)/unsquashfs-lzma
