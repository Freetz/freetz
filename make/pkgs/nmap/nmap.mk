$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_NMAP_VERSION_4),4.68,5.51))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH_4:=1866be3d8d397ea7721c08f520d033c208492d3e1551311805d18efbe6cef161
$(PKG)_HASH_5:=15b3e134a74fa9b54aba2c3a53d6701c7ad221dc4051657ef95465a5a5a8687e
$(PKG)_HASH:=$($(PKG)_HASH_$(call GET_MAJOR_VERSION,$($(PKG)_VERSION),1))
$(PKG)_SITE:=https://nmap.org/dist
### WEBSITE:=https://nmap.org/
### MANPAGE:=https://nmap.org/docs.html
### CHANGES:=https://nmap.org/changelog.html
### CVSREPO:=https://github.com/nmap/nmap

$(PKG)_CONDITIONAL_PATCHES+=$(call GET_MAJOR_VERSION,$($(PKG)_VERSION),1)

# make sure nmap never fallbacks to using the bundled libraries by deleting them
$(PKG)_PATCH_POST_CMDS += $(RM) -r libpcap libdnet-stripped $(if $(FREETZ_PACKAGE_NMAP_WITH_SHARED_LUA),liblua) $(if $(FREETZ_PACKAGE_NMAP_WITH_SHARED_PCRE),libpcre);

ifneq ($(strip $(FREETZ_PACKAGE_NMAP_VERSION_4)),y)
$(PKG)_BINARIES5_ALL       := ncat nping
$(PKG)_BINARIES5           := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_BINARIES5_ALL))
$(PKG)_BINARIES5_BUILD_DIR := $(addprefix $($(PKG)_DIR)/, $(join $($(PKG)_BINARIES5), $(addprefix /,$($(PKG)_BINARIES5))))
endif
$(PKG)_BINARIES_ALL        := nmap $($(PKG)_BINARIES5_ALL)
$(PKG)_BINARIES            := nmap $($(PKG)_BINARIES5)
$(PKG)_BINARIES_BUILD_DIR  := $($(PKG)_DIR)/nmap $($(PKG)_BINARIES5_BUILD_DIR)
$(PKG)_BINARIES_TARGET_DIR := $(addprefix $($(PKG)_DEST_DIR)/usr/bin/,$($(PKG)_BINARIES))

$(PKG)_DATADIR        := /usr/share/nmap

$(PKG)_DBS_ALL        := mac-prefixes os-db payloads protocols rpc service-probes services
$(PKG)_DBS            := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_DBS_ALL))

$(PKG)_DBS_BUILD_DIR  := $($(PKG)_DBS:%=$($(PKG)_DIR)/nmap-%)
$(PKG)_DBS_TARGET_DIR := $($(PKG)_DBS:%=$($(PKG)_DEST_DIR)$($(PKG)_DATADIR)/nmap-%)

$(PKG)_EXCLUDED       += $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))
$(PKG)_EXCLUDED       += $(patsubst %,$($(PKG)_DEST_DIR)$($(PKG)_DATADIR)/nmap-%,$(filter-out $($(PKG)_DBS),$($(PKG)_DBS_ALL)))

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_NMAP_VERSION_4
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_NMAP_VERSION_5
$(PKG)_REBUILD_SUBOPTS += FREETZ_STDCXXLIB
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_NMAP_WITH_SHARED_LUA
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_NMAP_WITH_SHARED_PCRE
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_NMAP_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG)_DEPENDS_ON += $(STDCXXLIB) libpcap libdnet
ifeq ($(strip $(FREETZ_PACKAGE_NMAP_WITH_SHARED_LUA)),y)
$(PKG)_DEPENDS_ON += lua
endif
$(PKG)_CONFIGURE_ENV += ac_cv_header_lua_h=$(if $(FREETZ_PACKAGE_NMAP_WITH_SHARED_LUA),yes,no)
ifeq ($(strip $(FREETZ_PACKAGE_NMAP_WITH_SHARED_PCRE)),y)
$(PKG)_DEPENDS_ON += pcre
endif

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)
$(PKG)_CONFIGURE_OPTIONS += --with-libpcap="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-libdnet="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-liblua=$(if $(FREETZ_PACKAGE_NMAP_WITH_SHARED_LUA),"$(TARGET_TOOLCHAIN_STAGING_DIR)/usr",included)
$(PKG)_CONFIGURE_OPTIONS += --with-libpcre=$(if $(FREETZ_PACKAGE_NMAP_WITH_SHARED_PCRE),"$(TARGET_TOOLCHAIN_STAGING_DIR)/usr",included)
# ssl support requires openssl built with ripemd enabled
$(PKG)_CONFIGURE_OPTIONS += --without-openssl
$(PKG)_CONFIGURE_OPTIONS += --without-zenmap

ifneq ($(strip $(FREETZ_PACKAGE_NMAP_VERSION_4)),y)
$(PKG)_CONFIGURE_OPTIONS += --with-ncat
$(PKG)_CONFIGURE_OPTIONS += --without-ndiff
$(PKG)_CONFIGURE_OPTIONS += --with-nping
else
# FREETZ_PACKAGE_NMAP_VERSION_4
$(PKG)_CONFIGURE_OPTIONS += --with-nmapfe=no
ifeq ($(strip $(FREETZ_PACKAGE_NMAP_WITH_SHARED_LUA)),y)
$(PKG)_CONFIGURE_ENV += LUAINCLUDE=-I"$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/lua"
endif
endif

# libnbase & libnsock:
# no extra configure options are required in order to use bundled versions of these libraries.


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(NMAP_DIR) $(if $(FREETZ_PACKAGE_NMAP_STATIC),STATIC="-static")

$(foreach binary,$($(PKG)_BINARIES_BUILD_DIR),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),/usr/bin)))

$($(PKG)_DBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	touch $@

$($(PKG)_DBS_TARGET_DIR): $($(PKG)_DEST_DIR)$($(PKG)_DATADIR)/nmap-%: $($(PKG)_DIR)/nmap-%
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR) $($(PKG)_DBS_TARGET_DIR)


$(pkg)-clean:
	-$(SUBMAKE) -C $(NMAP_DIR) clean
	$(RM) $(NMAP_DIR)/.configured

$(pkg)-uninstall:
	$(RM) -r $(NMAP_BINARIES_ALL:%=$(NMAP_DEST_DIR)/usr/bin/%) $(NMAP_DEST_DIR)$(NMAP_DATADIR)

$(PKG_FINISH)
