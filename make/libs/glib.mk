$(call PKG_INIT_LIB, 1.2.10)
$(PKG)_LIB_VERSION:=0.0.10
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=ftp://ftp.gtk.org/pub/gtk/v1.2
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/libglib-1.2.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libglib-1.2.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libglib-1.2.so.$($(PKG)_LIB_VERSION)
$(PKG)_SOURCE_MD5:=6fe30dad87c77b91b632def29dd69ef9

$(PKG)_CONFIGURE_DEFOPTS := n

$(PKG)_CONFIGURE_ENV += CC="$(TARGET_CC)"
$(PKG)_CONFIGURE_ENV += CFLAGS="$(TARGET_CFLAGS)"
$(PKG)_CONFIGURE_ENV += glib_cv_prog_cc_ansi_proto=no
$(PKG)_CONFIGURE_ENV += glib_cv_has__inline=yes
$(PKG)_CONFIGURE_ENV += glib_cv_has__inline__=yes
$(PKG)_CONFIGURE_ENV += glib_cv_hasinline=yes
$(PKG)_CONFIGURE_ENV += glib_cv_sane_realloc=yes
$(PKG)_CONFIGURE_ENV += glib_cv_va_copy=no
$(PKG)_CONFIGURE_ENV += glib_cv___va_copy=yes
$(PKG)_CONFIGURE_ENV += glib_cv_va_val_copy=yes
$(PKG)_CONFIGURE_ENV += glib_cv_rtldglobal_broken=no
$(PKG)_CONFIGURE_ENV += glib_cv_uscore=no
$(PKG)_CONFIGURE_ENV += glib_cv_func_pthread_mutex_trylock_posix=yes
$(PKG)_CONFIGURE_ENV += glib_cv_func_pthread_cond_timedwait_posix=yes
$(PKG)_CONFIGURE_ENV += glib_cv_sizeof_gmutex=24
$(PKG)_CONFIGURE_ENV += glib_cv_byte_contents_gmutex="0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"
$(PKG)_CONFIGURE_ENV += lt_cv_deplibs_check_method=pass_all
$(PKG)_CONFIGURE_ENV += lt_cv_path_NM="$(TARGET_MAKE_PATH)/$(TARGET_CROSS)nm -B"

$(PKG)_CONFIGURE_OPTIONS += --cache-file=$(FREETZ_BASE_DIR)/$(MAKE_DIR)/config.cache
$(PKG)_CONFIGURE_OPTIONS += --target=$(GNU_TARGET_NAME)
$(PKG)_CONFIGURE_OPTIONS += --host=$(GNU_TARGET_NAME)
$(PKG)_CONFIGURE_OPTIONS += --build=$(GNU_HOST_NAME)
$(PKG)_CONFIGURE_OPTIONS += --program-prefix=""
$(PKG)_CONFIGURE_OPTIONS += --program-suffix=""
$(PKG)_CONFIGURE_OPTIONS += --prefix=/usr
$(PKG)_CONFIGURE_OPTIONS += --exec-prefix=/usr
$(PKG)_CONFIGURE_OPTIONS += --bindir=/usr/bin
$(PKG)_CONFIGURE_OPTIONS += --datadir=/usr/share
$(PKG)_CONFIGURE_OPTIONS += --includedir=/usr/include
$(PKG)_CONFIGURE_OPTIONS += --infodir=/usr/share/info
$(PKG)_CONFIGURE_OPTIONS += --libdir=/usr/lib
$(PKG)_CONFIGURE_OPTIONS += --libexecdir=/usr/lib
$(PKG)_CONFIGURE_OPTIONS += --localstatedir=/var
$(PKG)_CONFIGURE_OPTIONS += --mandir=/usr/share/man
$(PKG)_CONFIGURE_OPTIONS += --sbindir=/usr/sbin
$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/etc
$(PKG)_CONFIGURE_OPTIONS += --with-gnu-ld
$(PKG)_CONFIGURE_OPTIONS += $(DISABLE_NLS)
$(PKG)_CONFIGURE_OPTIONS += $(DISABLE_LARGEFILE)
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(GLIB_DIR) \
		all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(GLIB_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libglib.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/glib.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/gmodule.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/gthread.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(GLIB_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libglib-1.2* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/glib-config \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/glib-1.2 \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/glib \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/glib.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/gmodule.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/gthread.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/aclocal/glib.m4 \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/info/glib.info \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/man/man?/glib-config*

$(pkg)-uninstall:
	$(RM) $(GLIB_TARGET_DIR)/libglib-1.2.so*

$(PKG_FINISH)
