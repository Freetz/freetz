$(call PKG_INIT_BIN, 1.0.4)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=X
$(PKG)_SITE:=git@https://github.com/catalinii/minisatip
### WEBSITE:=https://minisatip.org
### MANPAGE:=https://github.com/catalinii/minisatip/wiki
### CHANGES:=https://github.com/catalinii/minisatip/releases
### CVSREPO:=https://github.com/catalinii/minisatip

$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_WEBROOT := $($(PKG)_DIR)/html
$(PKG)_TARGET_WEBROOT := $($(PKG)_DEST_DIR)/usr/share/minisatip/html

$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_MINISATIP_HTML),,usr/share)


$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_KERNEL_VERSION_2_6_39_MAX),$(if $(FREETZ_KERNEL_VERSION_2_6_39_3),sendmmsg))

$(PKG)_CONFIGURE_OPTIONS += --disable-dvbca
$(PKG)_CONFIGURE_OPTIONS += --disable-netcv
$(PKG)_CONFIGURE_OPTIONS += --disable-axe
$(PKG)_CONFIGURE_OPTIONS += --disable-enigma

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MINISATIP_LINUXDVB
$(PKG)_CONFIGURE_OPTIONS += --$(if $(FREETZ_PACKAGE_MINISATIP_LINUXDVB),enable,disable)-linuxdvb

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MINISATIP_SATIPC
$(PKG)_CONFIGURE_OPTIONS += --$(if $(FREETZ_PACKAGE_MINISATIP_SATIPC),enable,disable)-satipc

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MINISATIP_DVBAPI
$(PKG)_CONFIGURE_OPTIONS += --$(if $(FREETZ_PACKAGE_MINISATIP_DVBAPI),enable,disable)-dvbapi

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MINISATIP_DVBAES
$(PKG)_CONFIGURE_OPTIONS += --$(if $(FREETZ_PACKAGE_MINISATIP_DVBAES),enable,disable)-dvbaes
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_MINISATIP_DVBAES),openssl)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MINISATIP_DVBCSA
$(PKG)_CONFIGURE_OPTIONS += --$(if $(FREETZ_PACKAGE_MINISATIP_DVBCSA),enable,disable)-dvbcsa
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_MINISATIP_DVBCSA),libdvbcsa)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MINISATIP_BACKTRACE
$(PKG)_CONFIGURE_ENV += ac_cv_func_backtrace=$(if $(FREETZ_PACKAGE_MINISATIP_BACKTRACE),yes,no)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)


$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(MINISATIP_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_WEBROOT): $($(PKG)_WEBROOT)
	$(INSTALL_DIR)


$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_WEBROOT)

$(pkg)-clean:
	-$(SUBMAKE) -C $(MINISATIP_DIR) clean
	$(RM) $(MINISATIP_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(MINISATIP_TARGET_BINARY)
	$(RM) -r $(MINISATIP_TARGET_WEBROOT)

$(PKG_FINISH)
