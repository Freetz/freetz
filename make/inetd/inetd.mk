$(call PKG_INIT_BIN, 0.2)
$(PKG)_PKG_VERSION:=$($(PKG)_VERSION)
$(PKG)_PKG_NAME:=inetd-$($(PKG)_PKG_VERSION)
$(PKG)_STARTLEVEL=14

$(PKG_UNPACKED)

$(pkg): $($(PKG)_TARGET_DIR)/.exclude 
$($(PKG)_TARGET_DIR)/.exclude: $(TOPDIR)/.config
	@echo -n "" > $@; \
	[ ! "$FREETZ_HAS_USB_HOST" == "y" -o "$FREETZ_REMOVE_FTPD" == "y" ] && echo -e "etc/default.ftpd/\nbin/inetdftp" >> $@; \
	[ ! "$FREETZ_HAS_USB_HOST" == "y" -o "$FREETZ_REMOVE_SMBD" == "y" -o "$FREETZ_PACKAGE_SAMBA" == "y" ] && echo -e "etc/default.smbd/\nbin/inetdsamba" >> $@; \
	touch $@

$(pkg):

$(pkg)-precompiled:

$(pkg)-clean:

$(PKG_FINISH)
