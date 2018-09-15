PATCHELF_HOST_VERSION:=0.9
PATCHELF_HOST_SOURCE:=patchelf-$(PATCHELF_HOST_VERSION).tar.bz2
PATCHELF_HOST_SOURCE_MD5:=d02687629c7e1698a486a93a0d607947
PATCHELF_HOST_SITE:=https://nixos.org/releases/patchelf/patchelf-$(PATCHELF_HOST_VERSION)

PATCHELF_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/patchelf-host
PATCHELF_HOST_DIR:=$(TOOLS_SOURCE_DIR)/patchelf-$(PATCHELF_HOST_VERSION)

patchelf-host-source: $(DL_DIR)/$(PATCHELF_HOST_SOURCE)
$(DL_DIR)/$(PATCHELF_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(PATCHELF_HOST_SOURCE) $(PATCHELF_HOST_SITE) $(PATCHELF_HOST_SOURCE_MD5)

patchelf-host-unpacked: $(PATCHELF_HOST_DIR)/.unpacked
$(PATCHELF_HOST_DIR)/.unpacked: $(DL_DIR)/$(PATCHELF_HOST_SOURCE) | $(TOOLS_SOURCE_DIR)
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xf $(DL_DIR)/$(PATCHELF_HOST_SOURCE)
	$(call APPLY_PATCHES,$(PATCHELF_HOST_MAKE_DIR)/patches,$(PATCHELF_HOST_DIR))
	touch $@

$(PATCHELF_HOST_DIR)/.configured: $(PATCHELF_HOST_DIR)/.unpacked
	(cd $(PATCHELF_HOST_DIR); $(RM) config.cache; \
		CFLAGS="-Wall -O2" \
		CC="$(TOOLS_CC)" \
		./configure \
		--prefix=/usr \
	);
	touch $@

$(PATCHELF_HOST_DIR)/src/patchelf: $(PATCHELF_HOST_DIR)/.configured
	$(MAKE) -C $(PATCHELF_HOST_DIR) all
	touch -c $@

$(TOOLS_DIR)/patchelf: $(PATCHELF_HOST_DIR)/src/patchelf
	$(INSTALL_FILE)
	strip $@

patchelf-host: $(TOOLS_DIR)/patchelf

patchelf-host-clean:
	-$(MAKE) -C $(PATCHELF_HOST_DIR) clean

patchelf-host-dirclean:
	$(RM) -r $(PATCHELF_HOST_DIR)

patchelf-host-distclean: patchelf-host-dirclean
	$(RM) $(TOOLS_DIR)/patchelf
