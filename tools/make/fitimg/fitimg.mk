FITIMG_VERSION:=0.2
FITIMG_SOURCE:=fitimg-$(FITIMG_VERSION).tar.gz
FITIMG_SOURCE_MD5:=00ea7049939935f0e9514c211110e53d
FITIMG_SITE:=https://boxmatrix.info/hosted/hippie2000

FITIMG_MAKE_DIR:=$(TOOLS_DIR)/make/fitimg
FITIMG_DIR:=$(TOOLS_SOURCE_DIR)/fitimg-$(FITIMG_VERSION)

fitimg-source: $(DL_DIR)/$(FITIMG_SOURCE)
$(DL_DIR)/$(FITIMG_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(FITIMG_SOURCE) $(FITIMG_SITE) $(FITIMG_SOURCE_MD5)

fitimg-unpacked: $(FITIMG_DIR)/.unpacked
$(FITIMG_DIR)/.unpacked: $(DL_DIR)/$(FITIMG_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(FITIMG_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(FITIMG_MAKE_DIR)/patches,$(FITIMG_DIR))
	touch $@

$(FITIMG_DIR)/fitimg: $(FITIMG_DIR)/.unpacked

$(TOOLS_DIR)/fitimg: $(FITIMG_DIR)/fitimg
	$(INSTALL_FILE)

fitimg: $(TOOLS_DIR)/fitimg


fitimg-clean:

fitimg-dirclean:
	$(RM) -r $(FITIMG_DIR)

fitimg-distclean: fitimg-dirclean
	$(RM) $(TOOLS_DIR)/fitimg


.PHONY: fitimg-source fitimg-unpacked fitimg fitimg-clean fitimg-dirclean fitimg-distclean
