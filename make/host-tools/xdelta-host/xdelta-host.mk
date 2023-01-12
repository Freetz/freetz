$(call TOOLS_INIT, 30q)
$(PKG)_SOURCE:=xdelta$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=750ab5f9e0b8f5f85c396f5005439503cc4b7f7d006e6c30814064d64dd3a494
$(PKG)_SITE:=http://xdelta.googlecode.com/files


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_NOP)

$($(PKG)_DIR)/xdelta3: $($(PKG)_DIR)/.unpacked
	$(TOOLS_SUBMAKE) CC="$(TOOLS_CC)" CXX="$(TOOLS_CXX)" CFLAGS="$(TOOLS_CFLAGS)" LDFLAGS="$(TOOLS_LDFLAGS)" -C $(XDELTA_HOST_DIR) xdelta3

$(TOOLS_DIR)/xdelta3: $($(PKG)_DIR)/xdelta3
	$(INSTALL_FILE)

$(pkg)-precompiled: $(TOOLS_DIR)/xdelta3


$(pkg)-clean:
	-$(MAKE) -C $(XDELTA_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(XDELTA_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(TOOLS_DIR)/xdelta3

$(TOOLS_FINISH)
