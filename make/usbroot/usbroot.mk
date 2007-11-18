$(call PKG_INIT_BIN, 0.1)

$(PACKAGES_DIR)/.$(pkg)-$($(PKG)_VERSION):
	mkdir -p $(USBROOT_TARGET_DIR)/root
	if test -d $(USBROOT_MAKE_DIR)/files; then \
	tar -c -C $(USBROOT_MAKE_DIR)/files --exclude=.svn . | tar -x -C $(USBROOT_TARGET_DIR) ; \
	fi
	@touch $@
    
usbroot: $(PACKAGES_DIR)/.$(pkg)-$($(PKG)_VERSION)
    
usbroot-precompiled: usbroot
    
usbroot-clean:
	rm -f $(PACKAGES_BUILD_DIR)/$(USBROOT_PKG_SOURCE)

$(PKG_FINISH)