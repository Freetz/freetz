$(call PKG_INIT_LIB, 7490.06.01)
$(PKG)_LIB_VERSION:=0.0.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_MD5:=2aeaa5eae6969419cd80f401e714170f
$(PKG)_SITE:=http://freetz.magenbrot.net

$(PKG)_BUILD_PREREQ += autoreconf

$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/libavmacl2.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libavmacl2.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libavmacl2.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_PRE_CMDS += touch AUTHORS ChangeLog COPYING NEWS README;
$(PKG)_CONFIGURE_PRE_CMDS += autoreconf -f -i;
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBAVMACL2_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBAVMACL2_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libavmacl2.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBAVMACL2_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libavmacl2.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/libavmacl2

$(pkg)-uninstall:
	$(RM) $(FLAC_TARGET_DIR)/libavmacl2*.so*

$(PKG_FINISH)
