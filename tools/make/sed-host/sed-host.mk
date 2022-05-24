$(call TOOLS_INIT, 4.8)
$(PKG)_SOURCE:=sed-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_SHA256:=f79b0cfea71b37a8eeec8490db6c5f7ae7719c35587f21edb0617f370eeff633
$(PKG)_SITE:=@GNU/sed


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked
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

$($(PKG)_DIR)/sed/sed: $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(SED_HOST_DIR) all
	touch -c $@

$(TOOLS_DIR)/sed: $($(PKG)_DIR)/sed/sed
	$(INSTALL_FILE)

$(pkg)-precompiled: $(TOOLS_DIR)/sed


$(pkg)-clean:
	-$(MAKE) -C $(SED_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(SED_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(TOOLS_DIR)/sed

$(TOOLS_FINISH)
