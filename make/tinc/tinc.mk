$(call PKG_INIT_BIN, 1.0.31)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=7a96f7eb12dfd43b21852b4207d860f2
$(PKG)_SITE:=http://www.tinc-vpn.org/packages

$(PKG)_BINARY:=$($(PKG)_DIR)/src/tincd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/tincd

$(PKG)_DEPENDS_ON += lzo openssl zlib

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TINC_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION

$(PKG)_HARDENING_OPTS := check_cflags___fPIE check_ldflags___pie
#$(PKG)_HARDENING_OPTS += check_ldflags___Wl__z_relro check_ldflags___Wl__z_now
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_MAKE_AC_VARIABLES_PACKAGE_SPECIFIC,$($(PKG)_HARDENING_OPTS),,ax)
$(PKG)_CONFIGURE_ENV += $(foreach opt,$($(PKG)_HARDENING_OPTS),$(pkg)_$(opt)=no)

$(PKG)_EXTRA_CFLAGS  += -ffunction-sections -fdata-sections
$(PKG)_EXTRA_LDFLAGS += -Wl,--gc-sections
ifeq ($(strip $(FREETZ_PACKAGE_TINC_STATIC)),y)
$(PKG)_EXTRA_LDFLAGS += -static
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(TINC_DIR) \
		EXTRA_CFLAGS="$(TINC_EXTRA_CFLAGS)" \
		EXTRA_LDFLAGS="$(TINC_EXTRA_LDFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(TINC_DIR) clean
	$(RM) $(TINC_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(TINC_TARGET_BINARY)

$(PKG_FINISH)
