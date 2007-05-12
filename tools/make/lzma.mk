LZMA_VERSION:=443
LZMA_SOURCE:=lzma$(LZMA_VERSION).tar.bz2
LZMA_SITE:=http://mesh.dl.sourceforge.net/sourceforge/sevenzip
LZMA_DIR:=$(SOURCE_DIR)/lzma$(LZMA_VERSION)
LZMA_MAKE_DIR:=$(TOOLS_DIR)/make
LZMA_ALONE_DIR:=$(LZMA_DIR)/C/7zip/Compress/LZMA_Alone
LZMA_LIB_DIR:=$(LZMA_DIR)/C/7zip/Compress/LZMA_Lib


$(DL_DIR)/$(LZMA_SOURCE):
	wget -P $(DL_DIR) $(LZMA_SITE)/$(LZMA_SOURCE)

$(LZMA_DIR)/.unpacked: $(DL_DIR)/$(LZMA_SOURCE)
	mkdir -p $(LZMA_DIR)
	tar -C $(LZMA_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(LZMA_SOURCE)
	for i in $(LZMA_MAKE_DIR)/patches/*.lzma.patch; do \
		patch -d $(LZMA_DIR) -p1 < $$i; \
	done
	touch $@

$(LZMA_ALONE_DIR)/lzma: $(LZMA_DIR)/.unpacked
	$(MAKE) -f makefile.gcc -C $(LZMA_ALONE_DIR)

$(LZMA_LIB_DIR)/liblzma.a: $(LZMA_DIR)/.unpacked
	$(MAKE) -C $(LZMA_LIB_DIR)
	touch -c $@

$(LZMA_DIR)/liblzma.a: $(LZMA_LIB_DIR)/liblzma.a
	cp -f $(LZMA_LIB_DIR)/liblzma.a $(LZMA_DIR)/liblzma.a

$(TOOLS_DIR)/lzma: $(LZMA_ALONE_DIR)/lzma
	cp $(LZMA_ALONE_DIR)/lzma $(TOOLS_DIR)/lzma

lzma: $(LZMA_DIR)/liblzma.a $(TOOLS_DIR)/lzma

lzma-source: $(LZMA_DIR)/.unpacked

lzma-clean:
	-$(MAKE) -C $(LZMA_LIB_DIR) clean
	rm -f $(LZMA_DIR)/liblzma.a

lzma-dirclean:
	rm -rf $(LZMA_DIR)

lzma-distclean: lzma-dirclean
	rm -f $(TOOLS_DIR)/lzma
