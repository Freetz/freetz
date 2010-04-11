$(call PKG_INIT_BIN, 4.68)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=c363d32a00c697d15996fced22072b6c
$(PKG)_SITE:=http://nmap.org/dist

$(PKG)_BINARY:=$($(PKG)_DIR)/nmap
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/nmap
$(PKG)_SERVICES_LIST:=$($(PKG)_DIR)/nmap-services
$(PKG)_TARGET_SERVICES_LIST:=$($(PKG)_DEST_DIR)/usr/share/nmap/nmap-services

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_NMAP_WITH_SHARED_LUA
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_NMAP_WITH_SHARED_PCRE

$(PKG)_DEPENDS_ON := uclibcxx libpcap libdnet
ifeq ($(strip $(FREETZ_PACKAGE_NMAP_WITH_SHARED_LUA)),y)
$(PKG)_DEPENDS_ON += lua
$(PKG)_CONFIGURE_ENV += LUAINCLUDE=-I"$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/lua"
endif
$(PKG)_CONFIGURE_ENV += ac_cv_header_lua_h=$(if $(FREETZ_PACKAGE_NMAP_WITH_SHARED_LUA),yes,no)
ifeq ($(strip $(FREETZ_PACKAGE_NMAP_WITH_SHARED_PCRE)),y)
$(PKG)_DEPENDS_ON += pcre
endif

$(PKG)_CONFIGURE_OPTIONS += --with-libpcap="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-libdnet="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-liblua=$(if $(FREETZ_PACKAGE_NMAP_WITH_SHARED_LUA),"$(TARGET_TOOLCHAIN_STAGING_DIR)/usr",included)
$(PKG)_CONFIGURE_OPTIONS += --with-libpcre=$(if $(FREETZ_PACKAGE_NMAP_WITH_SHARED_PCRE),"$(TARGET_TOOLCHAIN_STAGING_DIR)/usr",included)
$(PKG)_CONFIGURE_OPTIONS += --without-openssl
$(PKG)_CONFIGURE_OPTIONS += --with-nmapfe=no
$(PKG)_CONFIGURE_OPTIONS += --without-zenmap

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_SERVICES_LIST): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(NMAP_DIR)
	touch $(NMAP_SERVICES_LIST)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_SERVICES_LIST): $($(PKG)_SERVICES_LIST)
	mkdir -p $(dir $@)
	cp $^ $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_SERVICES_LIST)

$(pkg)-clean:
	-$(SUBMAKE) -C $(NMAP_DIR) clean
	$(RM) $(NMAP_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(NMAP_TARGET_BINARY)

$(PKG_FINISH)
