$(call PKG_INIT_BIN, 5.54)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA256:=5e8588a6c274b46b1d63e1b50f0725f4908dec736f6588eb48d1eb3d20c87902
$(PKG)_SITE:=https://www.stunnel.org/downloads/archive/5.x

$(PKG)_STARTLEVEL=81

$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/$(pkg)

$(PKG)_DEPENDS_ON += openssl

ifeq ($(strip $(FREETZ_PACKAGE_STUNNEL_BOXCERT)),y)
$(PKG)_CONDITIONAL_PATCHES+=boxcert
$(PKG)_DEPENDS_ON += privatekeypassword
$(PKG)_EXTRA_LDFLAGS += -lprivatekeypassword
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_STUNNEL_BOXCERT
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_STUNNEL_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG)_PATCH_POST_CMDS += $(call PKG_ADD_EXTRA_FLAGS,(C|LD)FLAGS|LIBS)

# reduce binary size by setting appropriate CFLAGS/LDFLAGS
$(PKG)_EXTRA_CFLAGS  += -ffunction-sections -fdata-sections
$(PKG)_EXTRA_LDFLAGS += -Wl,--gc-sections

ifeq ($(strip $(FREETZ_PACKAGE_STUNNEL_STATIC)),y)
$(PKG)_EXTRA_LDFLAGS += -all-static
$(PKG)_STATIC_LIBS += $(OPENSSL_LIBCRYPTO_EXTRA_LIBS)
endif

$(PKG)_CONFIGURE_ENV += ac_cv_file__dev_ptmx=no
$(PKG)_CONFIGURE_ENV += ac_cv_file__dev_ptc=no
$(PKG)_CONFIGURE_ENV += ac_cv_file__dev_urandom=yes

$(PKG)_CONFIGURE_OPTIONS += --disable-silent-rules
$(PKG)_CONFIGURE_OPTIONS += --disable-libwrap
$(PKG)_CONFIGURE_OPTIONS += --disable-systemd
$(PKG)_CONFIGURE_OPTIONS += --with-threads=pthread
$(PKG)_CONFIGURE_OPTIONS += --with-ssl="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(STUNNEL_DIR) \
		EXTRA_CFLAGS="$(STUNNEL_EXTRA_CFLAGS)" \
		EXTRA_LDFLAGS="$(STUNNEL_EXTRA_LDFLAGS)" \
		EXTRA_LIBS="$(STUNNEL_STATIC_LIBS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(STUNNEL_DIR) clean

$(pkg)-uninstall:
	$(RM) $(STUNNEL_TARGET_BINARY)

$(PKG_FINISH)
