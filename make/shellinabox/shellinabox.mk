$(call PKG_INIT_BIN, 2.14)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://shellinabox.googlecode.com/files
$(PKG)_SOURCE_MD5:=6c63b52edcebc56ee73a108e7211d174

$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)d
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)d

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

# touch configure.ac to prevent aclocal.m4 & configure from being regenerated
$(PKG)_CONFIGURE_PRE_CMDS += touch -t 200001010000.00 ./configure.ac ./Makefile.am;

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SHELLINABOX_SSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SHELLINABOX_BOXCERT
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SHELLINABOX_STATIC

ifeq ($(strip $(FREETZ_PACKAGE_SHELLINABOX_SSL)),y)
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION
$(PKG)_DEPENDS_ON += openssl
$(PKG)_CONFIGURE_OPTIONS += --enable-ssl
# will not work with SSL disabled, I suspect a bug in source??
$(PKG)_CONFIGURE_OPTIONS += --disable-runtime-loading
else
$(PKG)_CONFIGURE_OPTIONS += --disable-ssl
endif

ifeq ($(strip $(FREETZ_PACKAGE_SHELLINABOX_BOXCERT)),y)
$(PKG)_CONDITIONAL_PATCHES += boxcert
$(PKG)_DEPENDS_ON          += privatekeypassword
$(PKG)_EXTRA_CFLAGS        += $(if $(FREETZ_PACKAGE_SHELLINABOX_STATIC),-DCUSTOM_PRIVATEKEYPASSWORD_METHOD=PRIVATEKEYPASSWORD_METHOD_PROXY)
$(PKG)_EXTRA_LIBS          += -lprivatekeypassword
endif

$(PKG)_EXTRA_CFLAGS  += -ffunction-sections -fdata-sections
$(PKG)_EXTRA_LDFLAGS += -Wl,--gc-sections
$(PKG)_EXTRA_LDFLAGS += $(if $(FREETZ_PACKAGE_SHELLINABOX_STATIC),-all-static)
$(PKG)_EXTRA_LIBS    += -ldl -lm

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SHELLINABOX_DIR) \
		EXTRA_CFLAGS="$(SHELLINABOX_EXTRA_CFLAGS)" \
		shellinaboxd_EXTRA_LDFLAGS="$(SHELLINABOX_EXTRA_LDFLAGS)" \
		shellinaboxd_EXTRA_LIBS="$(SHELLINABOX_EXTRA_LIBS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SHELLINABOX_DIR) clean
	$(RM) $(SHELLINABOX_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(SHELLINABOX_TARGET_BINARY)

$(PKG_FINISH)
