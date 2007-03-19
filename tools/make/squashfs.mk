SQUASHFS_VERSION:=2.2
SQUASHFS_SOURCE:=squashfs$(SQUASHFS_VERSION).tar.gz
SQUASHFS_SITE:=http://mesh.dl.sourceforge.net/sourceforge/squashfs
SQUASHFS_DIR:=$(SOURCE_DIR)/squashfs$(SQUASHFS_VERSION)

MKSQUASHFS_DIR:=$(SQUASHFS_DIR)/squashfs-tools
MKSQUASHFS_MAKE_DIR:=$(TOOLS_DIR)/make

UNSQUASHFS_DIR:=$(SQUASHFS_DIR)/squashfs-tools
UNSQUASHFS_MAKE_DIR:=$(TOOLS_DIR)/make

SQUASHFS_LZMA_VERSION:=406
SQUASHFS_LZMA_DIR:=$(SOURCE_DIR)/lzma$(SQUASHFS_LZMA_VERSION)


$(DL_DIR)/$(SQUASHFS_SOURCE):
	wget -P $(DL_DIR) $(SQUASHFS_SITE)/$(SQUASHFS_SOURCE)

$(SQUASHFS_DIR)/.unpacked: $(DL_DIR)/$(SQUASHFS_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(SQUASHFS_SOURCE)
	for i in $(MKSQUASHFS_MAKE_DIR)/patches/*.squashfs.patch; do \
		patch -d $(SQUASHFS_DIR) -p0 < $$i; \
	done
	touch $@

$(MKSQUASHFS_DIR)/mksquashfs: $(SQUASHFS_DIR)/.unpacked
	$(MAKE) CC="$(TOOLS_CC)" \
		-C $(MKSQUASHFS_DIR) mksquashfs
	touch -c $@

$(MKSQUASHFS_DIR)/mksquashfs-lzma: $(SQUASHFS_DIR)/.unpacked $(SQUASHFS_LZMA_DIR)/liblzma.a
	$(MAKE) CXX="$(TOOLS_CXX)" \
		-C $(MKSQUASHFS_DIR) mksquashfs-lzma
	touch -c $@

$(UNSQUASHFS_DIR)/unsquashfs: $(SQUASHFS_DIR)/.unpacked
	$(MAKE) CC="$(TOOLS_CC)" \
		-C $(UNSQUASHFS_DIR) unsquashfs
	touch -c $@

$(UNSQUASHFS_DIR)/unsquashfs-lzma: $(SQUASHFS_DIR)/.unpacked $(SQUASHFS_LZMA_DIR)/liblzma.a
	$(MAKE) CXX="$(TOOLS_CXX)" \
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

squashfs: $(TOOLS_DIR)/mksquashfs $(TOOLS_DIR)/mksquashfs-lzma \
          $(TOOLS_DIR)/unsquashfs $(TOOLS_DIR)/unsquashfs-lzma

squashfs-source: $(SQUASHFS_DIR)/.unpacked

squashfs-clean:
	-$(MAKE) -C $(MKSQUASHFS_DIR) clean

squashfs-dirclean:
	rm -rf $(SQUASHFS_DIR)

squashfs-distclean: squashfs-dirclean
	rm -f $(TOOLS_DIR)/mksquashfs
	rm -f $(TOOLS_DIR)/mksquashfs-lzma
	rm -f $(TOOLS_DIR)/unsquashfs
	rm -f $(TOOLS_DIR)/unsquashfs-lzma
