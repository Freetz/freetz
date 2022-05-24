$(call PKG_INIT_BIN, 2.11)
$(PKG)_SOURCE:=nagios-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=0c4425401e0b9a8ba1d2e689fc8dd9a5016ee35ac5c66285d02eca393dd6cda5
$(PKG)_SITE:=@SF/nagios
$(PKG)_BINARY:=$($(PKG)_DIR)/base/nagios
$(PKG)_STATS_BINARY:=$($(PKG)_DIR)/base/nagiostats
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/nagios
$(PKG)_STATS_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/nagiostats

$(PKG)_DEPENDS_ON += microperl

$(PKG)_CONFIGURE_OPTIONS += --with-nagios-user="root"
$(PKG)_CONFIGURE_OPTIONS += --with-nagios-group="root"
$(PKG)_CONFIGURE_OPTIONS += --sysconfdir="/mod/etc/nagios"
$(PKG)_CONFIGURE_OPTIONS += --without-gd-lib
$(PKG)_CONFIGURE_OPTIONS += --without-gd-inc

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_STATS_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(NAGIOS_DIR) all

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_STATS_TARGET_BINARY): $($(PKG)_STATS_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_STATS_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(NAGIOS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(NAGIOS_TARGET_BINARY)

$(PKG_FINISH)
