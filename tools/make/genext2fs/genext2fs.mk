GENEXT2FS_VERSION:=20131004
GENEXT2FS_SOURCE:=genext2fs-$(GENEXT2FS_VERSION).tar.xz
# see http://genext2fs.cvs.sourceforge.net/viewvc/genext2fs/genext2fs/genext2fs.c?view=log for more info
GENEXT2FS_SITE:=cvs@pserver:anonymous@genext2fs.cvs.sourceforge.net:/cvsroot/genext2fs

GENEXT2FS_MAKE_DIR:=$(TOOLS_DIR)/make/genext2fs
GENEXT2FS_DIR:=$(TOOLS_SOURCE_DIR)/genext2fs-$(GENEXT2FS_VERSION)

genext2fs-source: $(DL_DIR)/$(GENEXT2FS_SOURCE)
$(DL_DIR)/$(GENEXT2FS_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(GENEXT2FS_SOURCE) $(GENEXT2FS_SITE) $(GENEXT2FS_SOURCE_MD5)

genext2fs-unpacked: $(GENEXT2FS_DIR)/.unpacked
$(GENEXT2FS_DIR)/.unpacked: $(DL_DIR)/$(GENEXT2FS_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(GENEXT2FS_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(GENEXT2FS_MAKE_DIR)/patches,$(GENEXT2FS_DIR))
	touch $@

$(GENEXT2FS_DIR)/.configured: $(GENEXT2FS_DIR)/.unpacked
	(cd $(GENEXT2FS_DIR); \
		mv configure.in configure.ac && \
		autoreconf -f -i && \
		./configure --prefix=$(FREETZ_BASE_DIR)/$(TOOLS_DIR) \
	);
	touch $@

$(GENEXT2FS_DIR)/genext2fs: $(GENEXT2FS_DIR)/.configured
	$(MAKE) -C $(GENEXT2FS_DIR) all
	touch -c $@

genext2fs-test: $(GENEXT2FS_DIR)/.tests-passed
$(GENEXT2FS_DIR)/.tests-passed: $(GENEXT2FS_DIR)/genext2fs
	(cd $(GENEXT2FS_DIR); ./test.sh)
	touch $@

$(TOOLS_DIR)/genext2fs: $(GENEXT2FS_DIR)/genext2fs $(GENEXT2FS_DIR)/.tests-passed
	$(INSTALL_FILE)
	strip $@

genext2fs: $(TOOLS_DIR)/genext2fs

genext2fs-clean:
	-$(MAKE) -C $(GENEXT2FS_DIR) clean
	$(RM) $(GENEXT2FS_DIR)/.configured $(GENEXT2FS_DIR)/.tests-passed

genext2fs-dirclean:
	$(RM) -r $(GENEXT2FS_DIR)

genext2fs-distclean: genext2fs-dirclean
	$(RM) $(TOOLS_DIR)/genext2fs
