$(call PKG_INIT_LIB, 2.20.5)
$(PKG)_LIB_VERSION:=0.2000.5
$(PKG)_SOURCE:=glib-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=ftp://ftp.gtk.org/pub/glib/2.20
$(PKG)_DIR:=$(SOURCE_DIR)/glib-$($(PKG)_VERSION)
$(PKG)_GLIB_BINARY:=$($(PKG)_DIR)/glib/.libs/libglib-2.0.so.$($(PKG)_LIB_VERSION)
$(PKG)_GOBJECT_BINARY:=$($(PKG)_DIR)/gobject/.libs/libgobject-2.0.so.$($(PKG)_LIB_VERSION)
$(PKG)_GMODULE_BINARY:=$($(PKG)_DIR)/gmodule/.libs/libgmodule-2.0.so.$($(PKG)_LIB_VERSION)
$(PKG)_GTHREAD_BINARY:=$($(PKG)_DIR)/gthread/.libs/libgthread-2.0.so.$($(PKG)_LIB_VERSION)
$(PKG)_GLIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libglib-2.0.so.$($(PKG)_LIB_VERSION)
$(PKG)_GOBJECT_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgobject-2.0.so.$($(PKG)_LIB_VERSION)
$(PKG)_GMODULE_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgmodule-2.0.so.$($(PKG)_LIB_VERSION)
$(PKG)_GTHREAD_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgthread-2.0.so.$($(PKG)_LIB_VERSION)
$(PKG)_GLIB_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libglib-2.0.so.$($(PKG)_LIB_VERSION)
$(PKG)_GOBJECT_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libgobject-2.0.so.$($(PKG)_LIB_VERSION)
$(PKG)_GMODULE_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libgmodule-2.0.so.$($(PKG)_LIB_VERSION)
$(PKG)_GTHREAD_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libgthread-2.0.so.$($(PKG)_LIB_VERSION)
$(PKG)_SOURCE_MD5:=4c178b91d82ef80a2da3c26b772569c0

$(PKG)_BUILD_PREREQ += glib-genmarshal
$(PKG)_BUILD_PREREQ_HINT := Hint: on Debian-like systems this binary is provided by the libglib2.0-dev package

$(PKG)_DEPENDS_ON := gettext pcre

# NB: glib2 does require iconv-functions, see glib/gconvert.c
# The configure option "--with-libiconv=no" means
# "do use the implementation provided by C library", i.e. by uClibc.
# As freetz' builds of uClibc prior to and excluding 0.9.29 do not
# provide them, we must use an extra library - the gnu-libiconv.
ifeq ($(strip $(FREETZ_TARGET_UCLIBC_VERSION_0_9_28)),y)
$(PKG)_DEPENDS_ON += libiconv
$(PKG)_CONFIGURE_OPTIONS += --with-libiconv=gnu
else
$(PKG)_CONFIGURE_OPTIONS += --with-libiconv=no
endif

$(PKG)_CONFIGURE_ENV += glib_cv_stack_grows=no
$(PKG)_CONFIGURE_ENV += glib_cv_uscore=no
$(PKG)_CONFIGURE_ENV += glib_cv_long_long_format=11
$(PKG)_CONFIGURE_ENV += glib_cv_have_strlcpy=yes
$(PKG)_CONFIGURE_ENV += ac_cv_func_mmap_fixed=yes
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-debug=no
$(PKG)_CONFIGURE_OPTIONS += --disable-mem-pools
$(PKG)_CONFIGURE_OPTIONS += --disable-rebuilds
$(PKG)_CONFIGURE_OPTIONS += --with-threads=posix
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk-doc
$(PKG)_CONFIGURE_OPTIONS += --disable-man
$(PKG)_CONFIGURE_OPTIONS += --with-pcre=system

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_GLIB_BINARY) $($(PKG)_GOBJECT_BINARY) $($(PKG)_GMODULE_BINARY) $($(PKG)_GTHREAD_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(GLIB2_DIR) \
		all

$($(PKG)_GLIB_STAGING_BINARY) $($(PKG)_GOBJECT_STAGING_BINARY) $($(PKG)_GMODULE_STAGING_BINARY) $($(PKG)_GTHREAD_STAGING_BINARY): \
	$($(PKG)_GLIB_BINARY) $($(PKG)_GOBJECT_BINARY) $($(PKG)_GMODULE_BINARY) $($(PKG)_GTHREAD_BINARY)
	$(SUBMAKE) -C $(GLIB2_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libglib-2.0.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgobject-2.0.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgmodule-2.0.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgthread-2.0.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/glib-2.0.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/gobject-2.0.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/gmodule-2.0.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/gmodule-no-export-2.0.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/gmodule-export-2.0.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/gthread-2.0.pc


$($(PKG)_GLIB_TARGET_BINARY): $($(PKG)_GLIB_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$($(PKG)_GOBJECT_TARGET_BINARY): $($(PKG)_GOBJECT_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$($(PKG)_GMODULE_TARGET_BINARY): $($(PKG)_GMODULE_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$($(PKG)_GTHREAD_TARGET_BINARY): $($(PKG)_GTHREAD_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_GLIB_STAGING_BINARY) $($(PKG)_GOBJECT_STAGING_BINARY) $($(PKG)_GMODULE_STAGING_BINARY) $($(PKG)_GTHREAD_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_GLIB_TARGET_BINARY) $($(PKG)_GOBJECT_TARGET_BINARY) $($(PKG)_GMODULE_TARGET_BINARY) $($(PKG)_GTHREAD_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(GLIB2_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		uninstall
	-$(SUBMAKE) -C $(GLIB2_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libglib-2.0* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgobject-2.0* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgmodule-2.0* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgthread-2.0*

$(pkg)-uninstall:
	$(RM) $(GLIB2_TARGET_DIR)/libglib-2.0.so* \
		$(GLIB2_TARGET_DIR)/libgobject-2.0.so* \
		$(GLIB2_TARGET_DIR)/libgmodule-2.0.so* \
		$(GLIB2_TARGET_DIR)/libgthread-2.0.so*

$(PKG_FINISH)
