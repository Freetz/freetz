UIMG_VERSION:=ffritz_6591_131219
UIMG_SOURCE:=uimg-$(UIMG_VERSION).tar.xz
UIMG_SOURCE_SHA256:=7e96a14c73c223188a9007bd0d30f48917e21d9454ab30ae7243251208a8e216
UIMG_SITE:=git_archive@git@bitbucket.org:fesc2000/ffritz.git,src/uimg
UIMG_DIR:=$(TOOLS_SOURCE_DIR)/uimg-$(UIMG_VERSION)
UIMG_MAKE_DIR:=$(TOOLS_DIR)/src/uimg
UIMG_TARGET_DIR:=$(TOOLS_DIR)

uimg-source: $(DL_DIR)/$(UIMG_SOURCE)
$(DL_DIR)/$(UIMG_SOURCE):
	$(DL_TOOL) $(DL_DIR) $(UIMG_SOURCE) $(UIMG_SITE) $(UIMG_SOURCE_SHA256)

uimg-unpacked: $(UIMG_DIR)/.unpacked
$(UIMG_DIR)/.unpacked: $(DL_DIR)/$(UIMG_SOURCE) | $(TOOLS_SOURCE_DIR)
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xf $(DL_DIR)/$(UIMG_SOURCE)
	$(call APPLY_PATCHES,$(UIMG_MAKE_DIR)/patches,$(UIMG_DIR))
	touch $@

$(UIMG_DIR)/src/uimg/uimg: $(UIMG_DIR)/.unpacked
	$(MAKE) -C $(UIMG_DIR)/src/uimg uimg

$(UIMG_TARGET_DIR)/uimg: $(UIMG_DIR)/src/uimg/uimg
	$(INSTALL_FILE)

uimg: $(UIMG_TARGET_DIR)/uimg

uimg-clean:
	$(RM) $(UIMG_DIR)/src/uimg/uimg

uimg-dirclean:
	$(RM) -r $(UIMG_DIR)

uimg-distclean: uimg-dirclean
	$(RM) $(UIMG_TARGET_DIR)/uimg

.PHONY: uimg-source uimg-unpacked uimg uimg-clean uimg-dirclean uimg-distclean
