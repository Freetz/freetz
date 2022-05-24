$(call PKG_INIT_BIN, 5.1)
$(PKG)_SOURCE:=gw6c-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=f34bbfd595fb2c0711f524c748b9279137a9e84367b6ad9470fa07c13043afd1
#$(PKG)_SITE:=http://go6.net/4105/file.asp?file_id=150
$(PKG)_SITE:=@MIRROR/

$(PKG)_BINARY:=$($(PKG)_DIR)/tspc-advanced/bin/gw6c
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/gw6c

$(PKG)_DEPENDS_ON += $(STDCXXLIB)
$(PKG)_REBUILD_SUBOPTS += FREETZ_STDCXXLIB

$(PKG)_MAKE_DEFINES += CC="$(TARGET_CC)"
$(PKG)_MAKE_DEFINES += CXX="$(TARGET_CXX)"
$(PKG)_MAKE_DEFINES += RANLIB="$(TARGET_RANLIB)"
$(PKG)_MAKE_DEFINES += ARCHIVER="$(TARGET_AR)"
$(PKG)_MAKE_DEFINES += ADDITIONAL_CPPFLAGS="$(TARGET_CFLAGS) -DNO_STDLIBCXX"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(GW6_DIR)/gw6c-config \
		$(GW6_MAKE_DEFINES)
	$(SUBMAKE) -C $(GW6_DIR)/gw6c-messaging \
		$(GW6_MAKE_DEFINES)
	$(SUBMAKE) -C $(GW6_DIR)/tspc-advanced \
		$(GW6_MAKE_DEFINES) \
		target="openwrt"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(GW6_DIR)/tspc-advanced $(GW6_MAKE_DEFINES) target=openwrt clean
	-$(SUBMAKE) -C $(GW6_DIR)/gw6c-messaging $(GW6_MAKE_DEFINES) clean
	-$(SUBMAKE) -C $(GW6_DIR)/gw6c-config $(GW6_MAKE_DEFINES) clean

$(pkg)-uninstall:
	$(RM) $(GW6_TARGET_BINARY)

$(PKG_FINISH)
