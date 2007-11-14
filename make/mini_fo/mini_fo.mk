$(call PKG_INIT_BIN, 0.3)

$(PACKAGES_DIR)/.$(pkg)-$($(PKG)_VERSION):
	mkdir -p $(MINI_FO_TARGET_DIR)/root
	if test -d $(MINI_FO_MAKE_DIR)/files; then \
	tar -c -C $(MINI_FO_MAKE_DIR)/files --exclude=.svn . | tar -x -C $(MINI_FO_TARGET_DIR) ; \
	fi
	@touch $@
    
mini_fo: $(PACKAGES_DIR)/.$(pkg)-$($(PKG)_VERSION)
    
mini_fo-precompiled: mini_fo
    
mini_fo-clean:
	rm -f $(PACKAGES_BUILD_DIR)/$(MINI_FO_PKG_SOURCE)

$(PKG_FINISH)