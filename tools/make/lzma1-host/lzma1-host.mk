LZMA1_HOST_VERSION:=465
LZMA1_HOST_SOURCE:=lzma$(LZMA1_HOST_VERSION).tar.bz2
LZMA1_HOST_SOURCE_MD5:=29d5ffd03a5a3e51aef6a74e9eafb759
LZMA1_HOST_SITE:=@SF/sevenzip

LZMA1_HOST_DIR:=$(TOOLS_SOURCE_DIR)/lzma$(LZMA1_HOST_VERSION)
LZMA1_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/lzma1-host

LZMA1_HOST_ALONE_DIR:=$(LZMA1_HOST_DIR)/CPP/7zip/Compress/LZMA_Alone
LZMA1_HOST_LIBC_DIR:=$(LZMA1_HOST_DIR)/C/LzmaLib
LZMA1_HOST_LIBCXX_DIR:=$(LZMA1_HOST_DIR)/CPP/7zip/Compress/LZMA_Lib


lzma1-host-source: $(DL_DIR)/$(LZMA1_HOST_SOURCE)
$(DL_DIR)/$(LZMA1_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(LZMA1_HOST_SOURCE) $(LZMA1_HOST_SITE) $(LZMA1_HOST_SOURCE_MD5)

lzma1-host-unpacked: $(LZMA1_HOST_DIR)/.unpacked
$(LZMA1_HOST_DIR)/.unpacked: $(DL_DIR)/$(LZMA1_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	mkdir -p $(LZMA1_HOST_DIR)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(LZMA1_HOST_SOURCE),$(LZMA1_HOST_DIR))
	$(call APPLY_PATCHES,$(LZMA1_HOST_MAKE_DIR)/patches,$(LZMA1_HOST_DIR))
	touch $@

$(LZMA1_HOST_ALONE_DIR)/lzma: $(LZMA1_HOST_DIR)/.unpacked
	$(TOOL_SUBMAKE) CC="$(TOOLS_CC)" CXX="$(TOOLS_CXX)" LDFLAGS="$(TOOLS_LDFLAGS)" -f makefile.gcc -C $(LZMA1_HOST_ALONE_DIR)

$(LZMA1_HOST_LIBC_DIR)/liblzma.a: $(LZMA1_HOST_DIR)/.unpacked
	$(TOOL_SUBMAKE) -f makefile.gcc -C $(LZMA1_HOST_LIBC_DIR)
	touch -c $@

$(LZMA1_HOST_LIBCXX_DIR)/liblzma++.a: $(LZMA1_HOST_DIR)/.unpacked
	$(TOOL_SUBMAKE) -f makefile.gcc -C $(LZMA1_HOST_LIBCXX_DIR)
	touch -c $@

$(LZMA1_HOST_DIR)/liblzma1.a: $(LZMA1_HOST_LIBC_DIR)/liblzma.a
	$(INSTALL_FILE)

$(LZMA1_HOST_DIR)/liblzma1++.a: $(LZMA1_HOST_LIBCXX_DIR)/liblzma++.a
	$(INSTALL_FILE)

$(TOOLS_DIR)/lzma: $(LZMA1_HOST_ALONE_DIR)/lzma
	$(INSTALL_FILE)

lzma1-host-precompiled: $(LZMA1_HOST_DIR)/liblzma1.a $(LZMA1_HOST_DIR)/liblzma1++.a $(TOOLS_DIR)/lzma


lzma1-host-clean:
	-$(MAKE) -C $(LZMA1_HOST_ALONE_DIR) clean
	-$(MAKE) -C $(LZMA1_HOST_LIBCXX_DIR) clean
	$(RM) $(LZMA1_HOST_DIR)/liblzma1*.a

lzma1-host-dirclean:
	$(RM) -r $(LZMA1_HOST_DIR)

lzma1-host-distclean: lzma1-host-dirclean
	$(RM) $(TOOLS_DIR)/lzma

