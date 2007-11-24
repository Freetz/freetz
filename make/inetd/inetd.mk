$(call PKG_INIT_BIN, 0.1)
$(PKG)_PKG_VERSION:=$($(PKG)_VERSION)
$(PKG)_PKG_NAME:=inetd-$($(PKG)_PKG_VERSION)
$(PKG)_STARTLEVEL=20

$(PKG_UNPACKED)

inetd-clean:
	rm -f $(PACKAGES_BUILD_DIR)/$(INETD_PKG_SOURCE)

# Nothing to do here at the moment
$(pkg)-uninstall:

$(PKG_FINISH)
