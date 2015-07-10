E2TOOLS_HOST_VERSION:=3158ef18a9
E2TOOLS_HOST_SOURCE:=e2tools-$(E2TOOLS_HOST_VERSION).tar.xz
E2TOOLS_HOST_SITE:=git@https://github.com/ndim/e2tools.git

E2TOOLS_HOST_DIR:=$(TOOLS_SOURCE_DIR)/e2tools-$(E2TOOLS_HOST_VERSION)
E2TOOLS_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/e2tools-host

E2TOOLS_HOST_LINKS:=e2ln e2ls e2mkdir e2mv e2rm e2tail
E2TOOLS_HOST_LINKS_TARGET_DIR:=$(addprefix $(TOOLS_DIR)/,$(E2TOOLS_HOST_LINKS))

e2tools-host-source: $(DL_DIR)/$(E2TOOLS_HOST_SOURCE)
$(DL_DIR)/$(E2TOOLS_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(E2TOOLS_HOST_SOURCE) $(E2TOOLS_HOST_SITE) $(E2TOOLS_HOST_SOURCE_MD5)

e2tools-host-unpacked: $(E2TOOLS_HOST_DIR)/.unpacked
$(E2TOOLS_HOST_DIR)/.unpacked: $(DL_DIR)/$(E2TOOLS_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(E2TOOLS_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(E2TOOLS_HOST_MAKE_DIR)/patches,$(E2TOOLS_HOST_DIR))
	touch $@

$(E2TOOLS_HOST_DIR)/.configured: $(E2FSPROGS_HOST_DIR)/.devel $(E2TOOLS_HOST_DIR)/.unpacked
	(cd $(E2TOOLS_HOST_DIR); \
		autoreconf -f -i && \
		PKG_CONFIG_PATH="$(E2FSPROGS_HOST_DEVEL_ROOT)/lib/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(E2FSPROGS_HOST_DEVEL_ROOT)/lib/pkgconfig" \
		./configure --prefix=/ \
	);
	touch $@

$(E2TOOLS_HOST_DIR)/e2cp: $(E2TOOLS_HOST_DIR)/.configured
	$(MAKE) -C $(E2TOOLS_HOST_DIR) all

$(TOOLS_DIR)/e2cp: $(E2TOOLS_HOST_DIR)/e2cp
	$(INSTALL_FILE)
	strip $@

$(E2TOOLS_HOST_LINKS_TARGET_DIR): $(TOOLS_DIR)/e2cp
	ln -sf $(notdir $<) $@

e2tools-host: $(TOOLS_DIR)/e2cp $(E2TOOLS_HOST_LINKS_TARGET_DIR)

e2tools-host-clean:
	-$(MAKE) -C $(E2TOOLS_HOST_DIR) clean

e2tools-host-dirclean:
	$(RM) -r $(E2TOOLS_HOST_DIR)

e2tools-host-distclean: e2tools-host-dirclean
	$(RM) $(TOOLS_DIR)/e2cp $(E2TOOLS_HOST_LINKS_TARGET_DIR)
