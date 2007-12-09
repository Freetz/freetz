$(call PKG_INIT_LIB, 2.12.12)
$(PKG)_LIB_VERSION:=0.1200.12
$(PKG)_SOURCE:=glib-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=ftp://ftp.gtk.org/pub/glib/2.12
$(PKG)_DIR:=$(SOURCE_DIR)/glib-$($(PKG)_VERSION)
$(PKG)_GLIB_BINARY:=$($(PKG)_DIR)/glib/.libs/libglib-2.0.so.$($(PKG)_LIB_VERSION)
$(PKG)_GOBJECT_BINARY:=$($(PKG)_DIR)/glib/.libs/libgobject-2.0.so.$($(PKG)_LIB_VERSION)
$(PKG)_GMODULE_BINARY:=$($(PKG)_DIR)/glib/.libs/libgmodule-2.0.so.$($(PKG)_LIB_VERSION)
$(PKG)_GTHREAD_BINARY:=$($(PKG)_DIR)/glib/.libs/libgthread-2.0.so.$($(PKG)_LIB_VERSION)
$(PKG)_GLIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libglib-2.0.so.$($(PKG)_LIB_VERSION)
$(PKG)_GOBJECT_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgobject-2.0.so.$($(PKG)_LIB_VERSION)
$(PKG)_GMODULE_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgmodule-2.0.so.$($(PKG)_LIB_VERSION)
$(PKG)_GTHREAD_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgthread-2.0.so.$($(PKG)_LIB_VERSION)
$(PKG)_GLIB_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libglib-2.0.so.$($(PKG)_LIB_VERSION)
$(PKG)_GOBJECT_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libgobject-2.0.so.$($(PKG)_LIB_VERSION)
$(PKG)_GMODULE_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libgmodule-2.0.so.$($(PKG)_LIB_VERSION)
$(PKG)_GTHREAD_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libgthread-2.0.so.$($(PKG)_LIB_VERSION)

$(PKG)_DEPENDS_ON += gettext libiconv

$(PKG)_CONFIGURE_ENV += glib_cv_stack_grows=no
$(PKG)_CONFIGURE_ENV += glib_cv_uscore=no
$(PKG)_CONFIGURE_ENV += glib_cv_long_long_format=11
$(PKG)_CONFIGURE_ENV += glib_cv_have_strlcpy=yes
$(PKG)_CONFIGURE_ENV += ac_cv_func_posix_getpwuid_r=yes
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-debug=no
$(PKG)_CONFIGURE_OPTIONS += --disable-mem-pools
$(PKG)_CONFIGURE_OPTIONS += --disable-rebuilds
$(PKG)_CONFIGURE_OPTIONS += --with-libiconv=gnu
$(PKG)_CONFIGURE_OPTIONS += --with-threads=posix
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk-doc
$(PKG)_CONFIGURE_OPTIONS += --disable-man

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_GLIB_BINARY) $($(PKG)_GOBJECT_BINARY) $($(PKG)_GMODULE_BINARY) $($(PKG)_GTHREAD_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(GLIB2_DIR) \
		all 

$($(PKG)_GLIB_STAGING_BINARY) $($(PKG)_GOBJECT_STAGING_BINARY) $($(PKG)_GMODULE_STAGING_BINARY) $($(PKG)_GTHREAD_STAGING_BINARY): \
	$($(PKG)_GLIB_BINARY) $($(PKG)_GOBJECT_BINARY) $($(PKG)_GMODULE_BINARY) $($(PKG)_GTHREAD_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(GLIB2_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libglib-2.0.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libgobject-2.0.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libgmodule-2.0.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libgthread-2.0.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/glib-2.0.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/gobject-2.0.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/gmodule-2.0.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/gmodule-no-export-2.0.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/gmodule-export-2.0.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/gthread-2.0.pc \


$($(PKG)_GLIB_TARGET_BINARY): $($(PKG)_GLIB_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libglib-2.0.so* $(GLIB2_TARGET_DIR)/
	$(TARGET_STRIP) $@

$($(PKG)_GOBJECT_TARGET_BINARY): $($(PKG)_GOBJECT_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgobject-2.0.so* $(GLIB2_TARGET_DIR)/
	$(TARGET_STRIP) $@

$($(PKG)_GMODULE_TARGET_BINARY): $($(PKG)_GMODULE_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgmodule-2.0.so* $(GLIB2_TARGET_DIR)/
	$(TARGET_STRIP) $@

$($(PKG)_GTHREAD_TARGET_BINARY): $($(PKG)_GTHREAD_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgthread-2.0.so* $(GLIB2_TARGET_DIR)/
	$(TARGET_STRIP) $@

$(pkg): $($(PKG)_STAGING_BINARY) $($(PKG)_GOBJECT_STAGING_BINARY) $($(PKG)_GMODULE_STAGING_BINARY) $($(PKG)_GTHREAD_STAGING_BINARY)

$(pkg)-precompiled: uclibc $(pkg) $($(PKG)_GLIB_TARGET_BINARY) \
	$($(PKG)_GOBJECT_TARGET_BINARY) $($(PKG)_GMODULE_TARGET_BINARY) $($(PKG)_GTHREAD_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(GLIB2_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libglib-2.0*
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgobject-2.0*
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgmodule-2.0*
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgthread-2.0*

$(pkg)-uninstall:
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(GLIB2_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		uninstall
	rm -f $(GLIB2_TARGET_DIR)/libglib-2.0.so*
	rm -f $(GLIB2_TARGET_DIR)/libglib-2.0.so*
	rm -f $(GLIB2_TARGET_DIR)/libgobject-2.0.so*
	rm -f $(GLIB2_TARGET_DIR)/libgmodule-2.0.so*
	rm -f $(GLIB2_TARGET_DIR)/libgthread-2.0.so*

$(PKG_FINISH)
