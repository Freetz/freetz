$(call PKG_INIT_BIN,0.6)
$(PKG)_STARTLEVEL=40

$(PKG_UNPACKED)

$(pkg)-cgi:

$(pkg)-cgi-precompiled:

$(pkg)-cgi-clean:
	rm -f $(PACKAGES_BUILD_DIR)/$(WOL_CGI_PKG_SOURCE)

$(PKG_FINISH)
