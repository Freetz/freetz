$(call PKG_INIT_BIN, 2.14)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://shellinabox.googlecode.com/files
$(PKG)_SOURCE_MD5:=6c63b52edcebc56ee73a108e7211d174

$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)d
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)d

ifeq ($(strip $(FREETZ_PACKAGE_SHELLINABOX_BOXCERT)),y)
$(PKG)_CONDITIONAL_PATCHES+=boxcert
$(PKG)_LDFLAGS += -ldl
endif

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

# touch configure.ac to prevent aclocal.m4 & configure from being regenerated
$(PKG)_CONFIGURE_PRE_CMDS += touch -t 200001010000.00 ./configure.ac;

$(PKG)_REBUILD_SUBOPTS +=  FREETZ_PACKAGE_SHELLINABOX_STATIC
$(PKG)_REBUILD_SUBOPTS +=  FREETZ_PACKAGE_SHELLINABOX_SSL

ifeq ($(strip $(FREETZ_PACKAGE_SHELLINABOX_SSL)),y)
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION
$(PKG)_DEPENDS_ON += openssl
$(PKG)_CONFIGURE_OPTIONS += --enable-ssl
# will not work with SSL disabled, I suspect a bug in source??
$(PKG)_CONFIGURE_OPTIONS += --disable-runtime-loading
else
$(PKG)_CONFIGURE_OPTIONS += --disable-ssl
endif

$(PKG)_LDFLAGS += -lm

ifeq ($(strip $(FREETZ_PACKAGE_SHELLINABOX_STATIC)),y)
$(PKG)_ADD_FLAGS += -lm -all-static -ldl -DSTATIC
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libprivatekeypassword.a $(SHELLINABOX_DIR)
	$(SUBMAKE) -C $(SHELLINABOX_DIR) \
		shellinaboxd_ADD="$(SHELLINABOX_ADD_FLAGS)" \
		LDFLAGS="$(SHELLINABOX_LDFLAGS)"

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
