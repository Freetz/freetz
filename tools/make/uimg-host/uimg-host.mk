UIMG_HOST_VERSION:=871930df297e3a03bc315be75ecfc8c5c7a809ab
UIMG_HOST_SOURCE:=uimg-$(UIMG_HOST_VERSION).tar.xz
UIMG_HOST_SOURCE_SHA256:=1f5b3b473f50c6ff79a7859be336245c39fc1d2b6c89baf862de6de1f7caf8e0
UIMG_HOST_SITE:=git@https://bitbucket.org/fesc2000/uimg-tool.git

UIMG_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/uimg-host
UIMG_HOST_DIR:=$(TOOLS_SOURCE_DIR)/uimg-$(UIMG_HOST_VERSION)


uimg-host-source: $(DL_DIR)/$(UIMG_HOST_SOURCE)
$(DL_DIR)/$(UIMG_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(UIMG_HOST_SOURCE) $(UIMG_HOST_SITE) $(UIMG_HOST_SOURCE_SHA256)

uimg-host-unpacked: $(UIMG_HOST_DIR)/.unpacked
$(UIMG_HOST_DIR)/.unpacked: $(DL_DIR)/$(UIMG_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(UIMG_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(UIMG_HOST_MAKE_DIR)/patches,$(UIMG_HOST_DIR))
	touch $@

$(UIMG_HOST_DIR)/uimg: $(UIMG_HOST_DIR)/.unpacked
	$(MAKE) CC="$(TOOLS_CC)" CXX="$(TOOLS_CXX)" CFLAGS="$(TOOLS_CFLAGS)" LDFLAGS="$(TOOLS_LDFLAGS)" -C $(UIMG_HOST_DIR) all $(QUIET)
	touch -c $@

$(TOOLS_DIR)/uimg: $(UIMG_HOST_DIR)/uimg
	$(INSTALL_FILE)

uimg-host-precompiled: $(TOOLS_DIR)/uimg


uimg-host-clean:
	-$(MAKE) -C $(UIMG_HOST_DIR) clean

uimg-host-dirclean:
	$(RM) -r $(UIMG_HOST_DIR)

uimg-host-distclean: uimg-host-dirclean
	$(RM) $(TOOLS_DIR)/uimg

