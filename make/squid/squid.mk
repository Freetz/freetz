$(call PKG_INIT_BIN, 3.0.STABLE9)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://www.squid-cache.org/Versions/v$(firstword $(subst ., ,$($(PKG)_VERSION)))/$(firstword $(subst ., ,$($(PKG)_VERSION))).$(word 2,$(subst ., ,$($(PKG)_VERSION)))
$(PKG)_BINARY:=$($(PKG)_DIR)/src/squid
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/squid
$(PKG)_SOURCE_MD5:=4009abfbf33d86f40db3ec4280716a0e 

$(PKG)_DEPENDS_ON := uclibcxx

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SQUID_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SQUID_DIR) clean
	$(RM) $(SQUID_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(SQUID_TARGET_BINARY)

$(PKG_FINISH)
