$(call PKG_INIT_BIN,1.2b)
$(PKG)_SOURCE:=mini_snmpd-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=9e432c50ba8216d7fab0983b11b7112a
$(PKG)_SITE:=http://members.aon.at/linuxfreak/linux
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/mini_snmpd
$(PKG)_BINARY:=$($(PKG)_DIR)/mini_snmpd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/mini_snmpd

ifeq ($(FREETZ_TARGET_IPV6_SUPPORT),y)
$(PKG)_CFLAGS:=-D__IPV6__
else
$(PKG)_CFLAGS:=-D__IPV4__
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(MINI_SNMPD_DIR) \
		CC="$(TARGET_CC)" \
		STRIP="$(TARGET_STRIP)" \
		OFLAGS="$(TARGET_CFLAGS) $(MINI_SNMPD_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(MINI_SNMPD_DIR) clean

$(pkg)-uninstall:
	$(RM) $(MINI_SNMPD_TARGET_BINARY)

$(PKG_FINISH)
