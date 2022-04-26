$(call TOOL_INIT, 4c1cc9468980448ca3e86db1cbe9600a4a084f5e)
$(TOOL)_SOURCE:=genext2fs-$($(TOOL)_VERSION).tar.xz
$(TOOL)_SOURCE_SHA256:=a59f657ce6d12013d7343c7b84928723f0b8dec4a89e9542802c1257dce26ba6
$(TOOL)_SITE:=git@https://github.com/bestouff/genext2fs.git
# see http://genext2fs.cvs.sourceforge.net/viewvc/genext2fs/genext2fs/genext2fs.c?view=log for more info
#$(TOOL)_VERSION:=20131004
#$(TOOL)_SOURCE_SHA256:=492052c02f774fa15e8d2dc0a49d0749d97ababbaf40ac7d3e93eda99b6fc777
#$(TOOL)_SITE:=cvs@pserver:anonymous@genext2fs.cvs.sourceforge.net:/cvsroot/genext2fs


$(tool)-source: $(DL_DIR)/$($(TOOL)_SOURCE)
$(DL_DIR)/$($(TOOL)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(GENEXT2FS_HOST_SOURCE) $(GENEXT2FS_HOST_SITE) $(GENEXT2FS_HOST_SOURCE_SHA256)

$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(DL_DIR)/$($(TOOL)_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(GENEXT2FS_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(GENEXT2FS_HOST_MAKE_DIR)/patches,$(GENEXT2FS_HOST_DIR))
	(cd $(GENEXT2FS_HOST_DIR); mv configure.in configure.ac)
	touch $@

$($(TOOL)_DIR)/.configured: $($(TOOL)_DIR)/.unpacked
	(cd $(GENEXT2FS_HOST_DIR); autoreconf -f -i $(SILENT); \
		CC="$(TOOLS_CC)" \
		CXX="$(TOOLS_CXX)" \
		CFLAGS="$(TOOLS_CFLAGS)" \
		LDFLAGS="$(TOOLS_LDFLAGS)" \
		./configure \
		--prefix=$(FREETZ_BASE_DIR)/$(TOOLS_DIR) \
		$(QUIET) \
	);
	touch $@

$($(TOOL)_DIR)/genext2fs: $($(TOOL)_DIR)/.configured
	$(TOOL_SUBMAKE) -C $(GENEXT2FS_HOST_DIR) all
	touch -c $@

$(tool)-test: $($(TOOL)_DIR)/.tests-passed
$($(TOOL)_DIR)/.tests-passed: $($(TOOL)_DIR)/genext2fs
	(cd $(GENEXT2FS_HOST_DIR); ./test.sh)
	touch $@

$(TOOLS_DIR)/genext2fs: $($(TOOL)_DIR)/genext2fs
	$(INSTALL_FILE)

$(tool)-precompiled: $(TOOLS_DIR)/genext2fs


$(tool)-clean:
	-$(MAKE) -C $(GENEXT2FS_HOST_DIR) clean
	$(RM) $(GENEXT2FS_HOST_DIR)/.configured $(GENEXT2FS_HOST_DIR)/.tests-passed

$(tool)-dirclean:
	$(RM) -r $(GENEXT2FS_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean
	$(RM) $(TOOLS_DIR)/genext2fs

$(TOOL_FINISH)
