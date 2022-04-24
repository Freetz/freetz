SED_HOST_VERSION:=4.8
SED_HOST_SOURCE:=sed-$(SED_HOST_VERSION).tar.xz
SED_HOST_SOURCE_SHA256:=f79b0cfea71b37a8eeec8490db6c5f7ae7719c35587f21edb0617f370eeff633
SED_HOST_SITE:=@GNU/sed

SED_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/sed-host
SED_HOST_DIR:=$(TOOLS_SOURCE_DIR)/sed-$(SED_HOST_VERSION)


sed-host-source: $(DL_DIR)/$(SED_HOST_SOURCE)
$(DL_DIR)/$(SED_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(SED_HOST_SOURCE) $(SED_HOST_SITE) $(SED_HOST_SOURCE_SHA256)

sed-host-unpacked: $(SED_HOST_DIR)/.unpacked
$(SED_HOST_DIR)/.unpacked: $(DL_DIR)/$(SED_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(SED_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(SED_HOST_MAKE_DIR)/patches,$(SED_HOST_DIR))
	touch $@

$(SED_HOST_DIR)/.configured: $(SED_HOST_DIR)/.unpacked
	(cd $(SED_HOST_DIR); $(RM) config.cache; \
		CC="$(TOOLS_CC)" \
		CXX="$(TOOLS_CXX)" \
		CFLAGS="$(TOOLS_CFLAGS)" \
		LDFLAGS="$(TOOLS_LDFLAGS)" \
		./configure \
		--prefix=/usr \
		--without-selinux \
		--disable-acl \
		$(DISABLE_NLS) \
		$(SILENT) \
	);
	touch $@

$(SED_HOST_DIR)/sed/sed: $(SED_HOST_DIR)/.configured
	$(MAKE) -C $(SED_HOST_DIR) all $(SILENT)
	touch -c $@

$(TOOLS_DIR)/sed: $(SED_HOST_DIR)/sed/sed
	$(INSTALL_FILE)

sed-host-precompiled: $(TOOLS_DIR)/sed


sed-host-clean:
	-$(MAKE) -C $(SED_HOST_DIR) clean

sed-host-dirclean:
	$(RM) -r $(SED_HOST_DIR)

sed-host-distclean: sed-host-dirclean
	$(RM) $(TOOLS_DIR)/sed

