$(call PKG_INIT_LIB, 2.0.22-stable)
$(PKG)_MAJOR_VERSION:=2.0
$(PKG)_SHLIB_VERSION:=5.1.9
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=c4c56f986aa985677ca1db89630a2e11
$(PKG)_SITE:=@SF/levent

$(PKG)_LIBNAME=$(pkg)-$($(PKG)_MAJOR_VERSION).so.$($(PKG)_SHLIB_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/$($(PKG)_LIBNAME)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_LIBNAME)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_MAKE_AC_VARIABLES_PACKAGE_SPECIFIC,header_zlib_h)
$(PKG)_CONFIGURE_ENV += $(pkg)_header_zlib_h=no

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-openssl

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBEVENT_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBEVENT_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install-strip
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libevent.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libevent.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP_WILDCARD_BEFORE_SO)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBEVENT_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libevent* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libevent.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/event2 \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/event.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/evdns.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/evhttp.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/evrpc.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/evutil.h

$(pkg)-uninstall:
	$(RM) $(LIBEVENT_TARGET_DIR)/libevent*.so*

$(PKG_FINISH)
