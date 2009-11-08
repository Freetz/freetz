$(call PKG_INIT_BIN, 1.1.2)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=ftp://bird.network.cz/pub/bird
$(PKG)_BINARY:=$($(PKG)_DIR)/bird
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/bird
$(PKG)_STARTLEVEL=80
$(PKG)_SOURCE_MD5:=183c0f8d0218230ca07f0a11afd01fc2 

ifeq ($(strip $(FREETZ_PACKAGE_BIRDC)),y)
$(PKG)_CLIENT_BINARY:=$($(PKG)_DIR)/birdc
$(PKG)_CLIENT_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/birdc

$(PKG)_DEPENDS_ON := ncurses readline
endif

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_BIRD_DEBUG
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_BIRDC

#$(PKG)_CONFIGURE_ENV += CFLAGS="$(TARGET_CFLAGS) -D_XOPEN_SOURCE=600"
#$(PKG)_CONFIGURE_ENV += CPPFLAGS="$(TARGET_CPPFLAGS) -D_XOPEN_SOURCE=600"
$(PKG)_CONFIGURE_ENV += bird_cv_c_endian=little-endian

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_BIRDC),--enable-client,--disable-client)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_BIRD_DEBUG),--enable-debug,--disable-debug)
$(PKG)_CONFIGURE_OPTIONS += --disable-memcheck
$(PKG)_CONFIGURE_OPTIONS += --disable-warnings
$(PKG)_CONFIGURE_OPTIONS += --disable-ipv6

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_CLIENT_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(BIRD_DIR) \
		LD="$(TARGET_LD)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

ifeq ($(strip $(FREETZ_PACKAGE_BIRDC)),y)
$($(PKG)_CLIENT_TARGET_BINARY): $($(PKG)_CLIENT_BINARY)
	$(INSTALL_BINARY_STRIP)
endif

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_CLIENT_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(BIRD_DIR) clean
	$(RM) $(BIRD_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(BIRD_TARGET_BINARY)
	$(RM) $(BIRD_CLIENT_TARGET_BINARY)

$(PKG_FINISH)
