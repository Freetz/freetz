$(call PKG_INIT_BIN, 0.1)
$(PKG)_PKG_VERSION:=$($(PKG)_VERSION)
$(PKG)_PKG_NAME:=inetd-$($(PKG)_PKG_VERSION)
$(PKG)_STARTLEVEL=20

$(PACKAGES_DIR)/.$($(PKG)_PKG_NAME):
	mkdir -p $(INETD_DEST_DIR)
	tar -c -C $(INETD_MAKE_DIR)/files --exclude=.svn . | tar -x -C $(INETD_DEST_DIR)
	@touch $@

inetd: $(PACKAGES_DIR)/.$($(PKG)_PKG_NAME)

inetd-precompiled: inetd

inetd-clean:
	rm -f $(PACKAGES_BUILD_DIR)/$(INETD_PKG_SOURCE)

inetd-uninstall:

$(PKG_FINISH)
