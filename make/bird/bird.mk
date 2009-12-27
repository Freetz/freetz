$(call PKG_INIT_BIN, 1.1.2)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=183c0f8d0218230ca07f0a11afd01fc2
$(PKG)_SITE:=ftp://bird.network.cz/pub/bird
$(PKG)_STARTLEVEL=80

$(PKG)_BINARIES_ALL := bird birdc
ifeq ($(strip $(FREETZ_PACKAGE_BIRDC)),y)
$(PKG)_DEPENDS_ON := ncurses readline
$(PKG)_BINARIES := $($(PKG)_BINARIES_ALL)
else
$(PKG)_BINARIES := $(filter-out birdc,$($(PKG)_BINARIES_ALL))
endif
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/sbin/%)

$(PKG)_NOT_INCLUDED := $(patsubst %,$($(PKG)_DEST_DIR)/usr/sbin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_BIRD_DEBUG
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_BIRDC

#$(PKG)_CONFIGURE_ENV += CFLAGS="$(TARGET_CFLAGS) -D_XOPEN_SOURCE=600"
#$(PKG)_CONFIGURE_ENV += CPPFLAGS="$(TARGET_CPPFLAGS) -D_XOPEN_SOURCE=600"
$(PKG)_CONFIGURE_ENV += bird_cv_c_endian=little-endian

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_BIRDC),--enable-client,--disable-client)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_BIRD_DEBUG),--enable-debug,--disable-debug)
$(PKG)_CONFIGURE_OPTIONS += --disable-memcheck
$(PKG)_CONFIGURE_OPTIONS += --disable-warnings
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),,--disable-ipv6)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(BIRD_DIR) \
		LD="$(TARGET_LD)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/sbin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(BIRD_DIR) clean
	$(RM) $(BIRD_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(BIRD_BINARIES_ALL:%=$(BIRD_DEST_DIR)/usr/sbin/%)

$(PKG_FINISH)
