$(call PKG_INIT_BIN, 0.2)
$(PKG)_STARTLEVEL=14

$(PKG)_EXCLUDED += $(if $(FREETZ_REMOVE_WEBSRV),,etc/default.websrv)
$(PKG)_EXCLUDED += $(if $(FREETZ_BUSYBOX_TELNETD),,etc/default.telnetd)
$(PKG)_EXCLUDED += $(if $(or $(call not-y,$(FREETZ_AVM_HAS_USB_HOST)),$(FREETZ_REMOVE_FTPD)),etc/default.ftpd bin/inetdftp)
$(PKG)_EXCLUDED += $(if $(or $(call not-y,$(FREETZ_AVM_HAS_USB_HOST)),$(FREETZ_REMOVE_SAMBA),$(FREETZ_PACKAGE_SAMBA_SMBD),$(FREETZ_AVM_HAS_SAMBA_NQCS)),etc/default.smbd bin/inetdsamba)
$(PKG)_EXCLUDED += $(if $(or $(call not-y,$(FREETZ_AVM_HAS_USB_HOST)),$(and $(or $(FREETZ_REMOVE_SAMBA),$(FREETZ_PACKAGE_SAMBA_SMBD),$(FREETZ_AVM_HAS_SAMBA_NQCS)),$(FREETZ_REMOVE_FTPD))),bin/inetdctl)

$(PKG_UNPACKED)

$(pkg):

$(pkg)-precompiled:

$(pkg)-clean:

$(PKG_FINISH)
