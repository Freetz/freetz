$(call TOOL_INIT, 465)
$(TOOL)_SOURCE:=lzma$($(TOOL)_VERSION).tar.bz2
$(TOOL)_SOURCE_MD5:=29d5ffd03a5a3e51aef6a74e9eafb759
$(TOOL)_SITE:=@SF/sevenzip

$(TOOL)_ALONE_DIR:=$($(TOOL)_DIR)/CPP/7zip/Compress/LZMA_Alone
$(TOOL)_LIBC_DIR:=$($(TOOL)_DIR)/C/LzmaLib
$(TOOL)_LIBCXX_DIR:=$($(TOOL)_DIR)/CPP/7zip/Compress/LZMA_Lib


$(tool)-source: $(DL_DIR)/$($(TOOL)_SOURCE)
$(DL_DIR)/$($(TOOL)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(LZMA1_HOST_SOURCE) $(LZMA1_HOST_SITE) $(LZMA1_HOST_SOURCE_MD5)

$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(DL_DIR)/$($(TOOL)_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	mkdir -p $(LZMA1_HOST_DIR)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(LZMA1_HOST_SOURCE),$(LZMA1_HOST_DIR))
	$(call APPLY_PATCHES,$(LZMA1_HOST_MAKE_DIR)/patches,$(LZMA1_HOST_DIR))
	touch $@

$($(TOOL)_ALONE_DIR)/lzma: $($(TOOL)_DIR)/.unpacked
	$(TOOL_SUBMAKE) CC="$(TOOLS_CC)" CXX="$(TOOLS_CXX)" LDFLAGS="$(TOOLS_LDFLAGS)" -f makefile.gcc -C $(LZMA1_HOST_ALONE_DIR)

$($(TOOL)_LIBC_DIR)/liblzma.a: $($(TOOL)_DIR)/.unpacked
	$(TOOL_SUBMAKE) -f makefile.gcc -C $(LZMA1_HOST_LIBC_DIR)
	touch -c $@

$($(TOOL)_LIBCXX_DIR)/liblzma++.a: $($(TOOL)_DIR)/.unpacked
	$(TOOL_SUBMAKE) -f makefile.gcc -C $(LZMA1_HOST_LIBCXX_DIR)
	touch -c $@

$($(TOOL)_DIR)/liblzma1.a: $($(TOOL)_LIBC_DIR)/liblzma.a
	$(INSTALL_FILE)

$($(TOOL)_DIR)/liblzma1++.a: $($(TOOL)_LIBCXX_DIR)/liblzma++.a
	$(INSTALL_FILE)

$(TOOLS_DIR)/lzma: $($(TOOL)_ALONE_DIR)/lzma
	$(INSTALL_FILE)

$(tool)-precompiled: $($(TOOL)_DIR)/liblzma1.a $($(TOOL)_DIR)/liblzma1++.a $(TOOLS_DIR)/lzma


$(tool)-clean:
	-$(MAKE) -C $(LZMA1_HOST_ALONE_DIR) clean
	-$(MAKE) -C $(LZMA1_HOST_LIBCXX_DIR) clean
	$(RM) $(LZMA1_HOST_DIR)/liblzma1*.a

$(tool)-dirclean:
	$(RM) -r $(LZMA1_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean
	$(RM) $(TOOLS_DIR)/lzma

$(TOOL_FINISH)
