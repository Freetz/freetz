$(call PKG_INIT_BIN,1.0)

$(PKG_UNPACKED)

$(PKG)_EXCLUDED += $(if $(FREETZ_SKIN_legacy),,usr/share/*/legacy)
$(PKG)_EXCLUDED += $(if $(FREETZ_SKIN_phoenix),,usr/share/*/phoenix)
$(PKG)_EXCLUDED += $(if $(FREETZ_SKIN_newfreetz),,usr/share/*/newfreetz)
$(PKG)_EXCLUDED += $(if $(FREETZ_STYLE_COLORED),usr/share/style/colorscheme-grey.css,usr/share/style/colorscheme-colored.css)

$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_MOD_ETCSERVICES),,etc/services)

$(PKG)_EXCLUDED += $(if $(or $(FREETZ_PACKAGE_MDEV),$(FREETZ_AVM_HAS_UDEV)),etc/device.table)
$(PKG)_EXCLUDED += $(if $(FREETZ_AVM_HAS_UDEV),,etc/udev)
$(PKG)_EXCLUDED += $(if $(FREETZ_CUSTOM_UDEV_RULES),,etc/default.mod/udev_*.def etc/udev/rules.d/??-custom.rules)
$(PKG)_EXCLUDED += $(if $(FREETZ_PATCH_FREETZMOUNT),,usr/lib/libmodmount.sh usr/lib/cgi-bin/mod/conf/30-mount.sh)

$(PKG)_EXCLUDED += $(if $(or $(call not-y,$(FREETZ_AVM_HAS_USB_HOST)),$(FREETZ_REMOVE_FTPD)),etc/init.d/rc.ftpd)
$(PKG)_EXCLUDED += $(if $(or $(call not-y,$(FREETZ_AVM_HAS_USB_HOST)),$(FREETZ_REMOVE_SAMBA),$(FREETZ_PACKAGE_SAMBA_SMBD)),etc/init.d/rc.smbd)
$(PKG)_EXCLUDED += $(if $(FREETZ_REMOVE_DSLD),usr/bin/wrapper/dsld etc/init.d/rc.dsld)
$(PKG)_EXCLUDED += $(if $(FREETZ_REMOVE_WEBSRV),,etc/init.d/rc.websrv usr/bin/websrv usr/lib/cgi-bin/conf.avm/30-websrv.sh)
$(PKG)_EXCLUDED += $(if $(or $(call not-y,$(EXTERNAL_ENABLED)),$(EXTERNAL_DOWNLOADER)),usr/lib/cgi-bin/mod/conf/40-external.sh etc/init.d/rc.external etc/external.pkg)

$(PKG)_EXCLUDED += $(if $(FREETZ_BUSYBOX_FEATURE_WTMP),,usr/lib/cgi-bin/mod/conf/60-utmp_wtmp.sh)
$(PKG)_EXCLUDED += $(if $(FREETZ_TARGET_IPV6_SUPPORT),,usr/lib/cgi-bin/mod/conf/90-ipv6.sh)

$(PKG)_EXCLUDED += $(if $(FREETZ_STRIP_SCRIPTS),usr/share/abo??.txt)
$(PKG)_EXCLUDED += $(if $(FREETZ_REMOVE_BOX_INFO),usr/lib/cgi-bin/mod/box_info.cgi)
$(PKG)_EXCLUDED += $(if $(FREETZ_REMOVE_FREETZ_INFO),usr/lib/cgi-bin/mod/do_download_config.cgi usr/lib/cgi-bin/mod/info.cgi)

$(pkg):

$(pkg)-precompiled:

$(pkg)-clean:

$(PKG_FINISH)
