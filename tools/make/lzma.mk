LZMA_VERSION:=406
LZMA_SOURCE:=lzma$(LZMA_VERSION).zip
LZMA_SITE:=http://www.7-zip.org/dl
LZMA_DIR:=$(SOURCE_DIR)/lzma$(LZMA_VERSION)
LZMA_MAKE_DIR:=$(TOOLS_DIR)/make
LZMA_ALONE_DIR:=$(LZMA_DIR)/SRC/7zip/Compress/LZMA_Alone
LZMA_LIB_DIR:=$(LZMA_DIR)/SRC/7zip/Compress/LZMA_Lib


$(DL_DIR)/$(LZMA_SOURCE):
	wget -P $(DL_DIR) $(LZMA_SITE)/$(LZMA_SOURCE)

$(LZMA_DIR)/.unpacked: $(DL_DIR)/$(LZMA_SOURCE)
	@rm -rf $(LZMA_DIR) && mkdir -p $(LZMA_DIR)
	unzip -q $(DL_DIR)/$(LZMA_SOURCE) -d $(LZMA_DIR)
	chmod -R +w $(LZMA_DIR)
	dos2unix $(LZMA_DIR)/SRC/7zip/Compress/LZMA/LZMADecoder.*
	for i in $(LZMA_MAKE_DIR)/patches/*.lzma.patch; do \
		patch -d $(LZMA_DIR) -p0 < $$i; \
	done
	touch $@

$(LZMA_ALONE_DIR)/lzma: $(LZMA_DIR)/.unpacked
	$(MAKE) CXX="$(TOOLS_CXX) -O3 -Wall" \
		-C $(LZMA_ALONE_DIR)

$(LZMA_LIB_DIR)/liblzma.a: $(LZMA_DIR)/.unpacked
	$(MAKE) CXX="$(TOOLS_CXX) -O3 -Wall" AR="$(TOOLS_AR)" \
		-C $(LZMA_LIB_DIR)
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
