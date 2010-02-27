$(call PKG_INIT_BIN, 3.0.STABLE24)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=325c8977b64397666bf538d54bb6f128
$(PKG)_SITE:=http://www.squid-cache.org/Versions/v$(firstword $(subst ., ,$($(PKG)_VERSION)))/$(firstword $(subst ., ,$($(PKG)_VERSION))).$(word 2,$(subst ., ,$($(PKG)_VERSION)))
$(PKG)_BINARY:=$($(PKG)_DIR)/src/squid
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/squid

$(PKG)_DEPENDS_ON := uclibcxx

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SQUID_TRANSPARENT

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_SQUID_TRANSPARENT),--enable-linux-netfilter,--disable-linux-netfilter)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(SQUID_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(SQUID_DIR) clean
	$(RM) $(SQUID_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(SQUID_TARGET_BINARY)

$(PKG_FINISH)
