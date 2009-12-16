$(call PKG_INIT_LIB, 2.0.35)
$(PKG)_LIB_VERSION:=2.0.0
$(PKG)_SOURCE:=gd-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://www.libgd.org/releases
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/libgd.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgd.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libgd.so.$($(PKG)_LIB_VERSION)
$(PKG)_SOURCE_MD5:=6c6c3dbb7bf079e0bb5fbbfd3bb8a71c

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

#$(PKG)_CONFIGURE_OPTIONS += --disable-pthreads?

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(GD_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_PATH) $(MAKE) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		-C $(GD_DIR) install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgd.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/gdlib-config

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(GD_DIR) clean
	$(RM) $(LIBGD_FREETZ_CONFIG_FILE)
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgd.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/include/gd \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/bin/gdlib-config

$(pkg)-uninstall:
	$(RM) $(LIBGD_TARGET_DIR)/libgd*.so*

$(PKG_FINISH)
