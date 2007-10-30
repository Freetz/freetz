$(eval $(call PKG_INIT_LIB, 2.3.19))
$(PKG)_LIB_VERSION:=$($(PKG)_VERSION)
$(PKG)_SOURCE:=libart_lgpl-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://ftp.gnome.org/pub/gnome/sources/libart_lgpl/2.3/
$(PKG)_DIR:=$(SOURCE_DIR)/libart_lgpl-$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/libart_lgpl_2.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libart_lgpl_2.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libart_lgpl_2.so.$($(PKG)_LIB_VERSION)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)


$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LIBART_DIR) all \
		HOSTCC="$(HOSTCC)"

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) -C $(LIBART_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(SED) 's,-I$${includedir}/libart-2.0,,g' $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libart-2.0.pc 
	$(SED) 's,-L$${libdir},,g' $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libart-2.0.pc 
	$(SED) -i -e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libart_lgpl_2.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libart*.so* $(LIBART_TARGET_DIR)
	$(TARGET_STRIP) $@

libart: $($(PKG)_STAGING_BINARY)

libart-precompiled: uclibc libart $($(PKG)_TARGET_BINARY)

libart-clean:
	-$(MAKE) -C $(LIBART_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libart*

libart-uninstall:
	rm -f $(LIBART_TARGET_DIR)/libart*.so*

$(PKG_FINISH)
