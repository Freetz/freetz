$(call PKG_INIT_BIN, de7bf5575e)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_CHECKSUM:=X
$(PKG)_SITE:=git@https://github.com/catalinii/minisatip

$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_WEBROOT_DIR := /usr/share/minisatip/html
$(PKG)_WEBROOT_ALL := dLAN.xml dvbc.png dvbc2.png dvbs.png dvbs2.png dvbs2x.png dvbt.png dvbt2.png \
	jquery-3.2.1.min.js jquery.dataTables.min.css jquery.dataTables.min.js jquery.pBar.min.js lr.jpg \
	lr.png satip.xml sm.jpg sm.png sort_asc.png sort_both.png sort_desc.png status.html
# tar tvf dl/minisatip-... | sed -rn 's,.*/html/, ,p' | tr -d '\n'

$(PKG)_WEBROOT := $(if $(FREETZ_PACKAGE_MINISATIP_HTML),$($(PKG)_WEBROOT_ALL))
$(PKG)_WEBROOT_BUILD_DIR := $($(PKG)_WEBROOT:%=$($(PKG)_DIR)/html/%)
$(PKG)_WEBROOT_TARGET_DIR := $($(PKG)_WEBROOT:%=$($(PKG)_DEST_DIR)$($(PKG)_WEBROOT_DIR)/%)

$(PKG)_EXCLUDED += $(patsubst %,$($(PKG)_DEST_DIR)$($(PKG)_WEBROOT_DIR)/%,$(filter-out $($(PKG)_WEBROOT),$($(PKG)_WEBROOT_ALL)))
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MINISATIP_HTML

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

$($(PKG)_WEBROOT_BUILD_DIR): $($(PKG)_DIR)/.unpacked

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_WEBROOT_TARGET_DIR): $($(PKG)_DEST_DIR)$($(PKG)_WEBROOT_DIR)/%: $($(PKG)_DIR)/html/%
	$(INSTALL_FILE)
	@chmod 644 $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_WEBROOT_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(MINISATIP_DIR) clean
	$(RM) $(MINISATIP_DIR)/.configured

$(pkg)-uninstall:
	$(RM) -r $(MINISATIP_TARGET_BINARY) $(MINISATIP_DEST_DIR)$(MNISATIP_WEBROOT_DIR)

$(PKG_FINISH)
