$(call PKG_INIT_LIB, 665)
$(PKG)_LIB_VERSION:=1.0.1
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=139daed4c5158b20c1fd65d5152d48c4414bb9947b48f1961084e8409c4c8fb4
# release URL
# $(PKG)_SITE:=http://libdnet.googlecode.com/files
$(PKG)_SITE:=svn@http://libdnet.googlecode.com/svn/trunk

$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg).so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --with-python=no
$(PKG)_CONFIGURE_OPTIONS += --with-wpdpack=no
$(PKG)_CONFIGURE_OPTIONS += --with-check=no

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBDNET_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBDNET_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libdnet.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/dnet-config

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBDNET_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libdnet* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/dnet \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/dnet.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/dnet-config

$(pkg)-uninstall:
	$(RM) $(LIBDNET_TARGET_DIR)/libdnet*

$(PKG_FINISH)
