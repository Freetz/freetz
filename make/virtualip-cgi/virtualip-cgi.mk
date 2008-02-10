$(call PKG_INIT_BIN, 0.4.2)
$(PKG)_STARTLEVEL=10

$(PKG_UNPACKED)

$(pkg)-cgi:

$(pkg)-cgi-precompiled:

$(pkg)-cgi-clean:
	$(RM) $(PACKAGES_BUILD_DIR)/$(VIRTUALIP_CGI_PKG_SOURCE)

$(PKG_FINISH)
