YOURFRITZ_HOST_VERSION:=2abe5f1fa8
YOURFRITZ_HOST_SOURCE:=yourfritz-$(YOURFRITZ_HOST_VERSION).tar.xz
YOURFRITZ_HOST_SITE:=git@https://github.com/PeterPawn/YourFritz.git

YOURFRITZ_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/yourfritz-host
YOURFRITZ_HOST_DIR:=$(TOOLS_SOURCE_DIR)/yourfritz-$(YOURFRITZ_HOST_VERSION)

yourfritz-host-source: $(DL_DIR)/$(YOURFRITZ_HOST_SOURCE)
$(DL_DIR)/$(YOURFRITZ_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(YOURFRITZ_HOST_SOURCE) $(YOURFRITZ_HOST_SITE) $(YOURFRITZ_HOST_SOURCE_MD5)

yourfritz-host-unpacked: $(YOURFRITZ_HOST_DIR)/.unpacked
$(YOURFRITZ_HOST_DIR)/.unpacked: $(DL_DIR)/$(YOURFRITZ_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(TAR) -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xf $(DL_DIR)/$(YOURFRITZ_HOST_SOURCE)
	$(call APPLY_PATCHES,$(YOURFRITZ_HOST_MAKE_DIR)/patches,$(YOURFRITZ_HOST_DIR))
	touch $@

$(YOURFRITZ_HOST_DIR)/.symlinked: | $(YOURFRITZ_HOST_DIR)/.unpacked
	@ln -Tsf ../$(YOURFRITZ_HOST_DIR:$(FREETZ_BASE_DIR)/%=%) $(TOOLS_DIR)/yf
	touch $@

yourfritz-host: $(YOURFRITZ_HOST_DIR)/.symlinked

yourfritz-host-clean:

yourfritz-host-dirclean:
	$(RM) -r $(YOURFRITZ_HOST_DIR)

yourfritz-host-distclean: yourfritz-host-dirclean
	$(RM) $(TOOLS_DIR)/yf
