$(call PKG_INIT_BIN,0.2)
$(PKG)_STARTLEVEL=20

$(PKG_UNPACKED)

$(pkg)-cgi:

$(pkg)-cgi-precompiled:

$(pkg)-cgi-clean:
	$(RM) $(PACKAGES_BUILD_DIR)/$(SPINDOWN_CGI_PKG_SOURCE)

$(PKG_FINISH)
