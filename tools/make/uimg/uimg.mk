UIMG_VERSION:=871930df297e3a03bc315be75ecfc8c5c7a809ab
UIMG_SOURCE:=uimg-$(UIMG_VERSION).tar.xz
UIMG_SOURCE_SHA256:=1f5b3b473f50c6ff79a7859be336245c39fc1d2b6c89baf862de6de1f7caf8e0
UIMG_SITE:=git@https://bitbucket.org/fesc2000/uimg-tool.git

UIMG_MAKE_DIR:=$(TOOLS_DIR)/make/uimg
UIMG_DIR:=$(TOOLS_SOURCE_DIR)/uimg-$(UIMG_VERSION)

uimg-source: $(DL_DIR)/$(UIMG_SOURCE)
$(DL_DIR)/$(UIMG_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(UIMG_SOURCE) $(UIMG_SITE) $(UIMG_SOURCE_SHA256)

uimg-unpacked: $(UIMG_DIR)/.unpacked
$(UIMG_DIR)/.unpacked: $(DL_DIR)/$(UIMG_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(UIMG_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(UIMG_MAKE_DIR)/patches,$(UIMG_DIR))
	touch $@












$(UIMG_DIR)/uimg: $(UIMG_DIR)/.unpacked
	$(MAKE) -C $(UIMG_DIR) all
	touch -c $@

$(TOOLS_DIR)/uimg: $(UIMG_DIR)/uimg
	$(INSTALL_FILE)

uimg: $(TOOLS_DIR)/uimg

uimg-clean:
	-$(MAKE) -C $(UIMG_DIR) clean

uimg-dirclean:
	$(RM) -r $(UIMG_DIR)

uimg-distclean: uimg-dirclean
	$(RM) $(TOOLS_DIR)/uimg

.PHONY: uimg-source uimg-unpacked uimg uimg-clean uimg-dirclean uimg-distclean
