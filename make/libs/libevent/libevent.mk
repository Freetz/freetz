$(call PKG_INIT_LIB, 2.1.12-stable)
$(PKG)_MAJOR_VERSION:=2.1
$(PKG)_SHLIB_VERSION:=7.0.1
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=92e6de1be9ec176428fd2367677e61ceffc2ee1cb119035037a27d346b0403bb
$(PKG)_SITE:=https://github.com/libevent/libevent/releases/download/release-$($(PKG)_VERSION)
### WEBSITE:=https://libevent.org/
### MANPAGE:=https://libevent.org/libevent-book/
### CHANGES:=https://github.com/libevent/libevent/releases
### CVSREPO:=https://github.com/libevent/libevent

$(PKG)_LIBNAME=$(pkg)-$($(PKG)_MAJOR_VERSION).so.$($(PKG)_SHLIB_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/$($(PKG)_LIBNAME)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_LIBNAME)

# zlib is needed only for tests, pretend not to have it to avoid the run-time dependency
$(PKG)_CONFIGURE_ENV += ac_cv_header_zlib_h=no

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-thread-support
$(PKG)_CONFIGURE_OPTIONS += --enable-function-sections
$(PKG)_CONFIGURE_OPTIONS += --disable-openssl
$(PKG)_CONFIGURE_OPTIONS += --disable-debug-mode
$(PKG)_CONFIGURE_OPTIONS += --disable-libevent-regress
$(PKG)_CONFIGURE_OPTIONS += --disable-samples


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
