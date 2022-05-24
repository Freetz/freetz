$(call TOOLS_INIT, 30q)
$(PKG)_SOURCE:=xdelta$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=633717fb1b3fa77374dc1f3549cc7b59
$(PKG)_SITE:=http://xdelta.googlecode.com/files

$(PKG)_DIR:=$(TOOLS_SOURCE_DIR)/xdelta$($(PKG)_VERSION)


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
