$(eval $(call PKG_INIT_LIB, 1.3e))
$(PKG)_LIB_VERSION:=1.0.3
$(PKG)_SOURCE:=libevent-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.monkey.org/~provos
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/libevent-$($(PKG)_VERSION).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libevent-$($(PKG)_VERSION).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libevent-$($(PKG)_VERSION).so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-static

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
	   $(MAKE) -C $(LIBEVENT_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LIBEVENT_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install-strip
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libevent.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libevent*.so* $(LIBEVENT_TARGET_DIR)/
	$(TARGET_STRIP) $@

libevent: $($(PKG)_STAGING_BINARY)

libevent-precompiled: uclibc libevent $($(PKG)_TARGET_BINARY)

libevent-clean:
	-$(MAKE) -C $(LIBEVENT_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libevent*

libevent-uninstall:
	rm -f $(LIBEVENT_TARGET_DIR)/libevent*.so*

$(PKG_FINISH)
