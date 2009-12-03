$(call PKG_INIT_LIB, 2.20.5)
$(PKG)_LIB_VERSION:=0.2000.5
$(PKG)_MAJOR_VERSION:=2.0
$(PKG)_SOURCE:=glib-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=4c178b91d82ef80a2da3c26b772569c0
$(PKG)_SITE:=ftp://ftp.gtk.org/pub/glib/2.20
$(PKG)_DIR:=$(SOURCE_DIR)/glib-$($(PKG)_VERSION)

$(PKG)_LIBNAMES_SHORT := glib gobject gmodule gthread gio
$(PKG)_LIBNAMES_LONG := $($(PKG)_LIBNAMES_SHORT:%=lib%-$($(PKG)_MAJOR_VERSION).so.$($(PKG)_LIB_VERSION))
$(PKG)_LIBS_BUILD_DIR := $(join $($(PKG)_LIBNAMES_SHORT:%=$($(PKG)_DIR)/%/.libs/),$($(PKG)_LIBNAMES_LONG))
$(PKG)_LIBS_STAGING_DIR := $($(PKG)_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)
$(PKG)_LIBS_TARGET_DIR := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_TARGET_DIR)/%)

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

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_ENV += glib_cv_stack_grows=no
$(PKG)_CONFIGURE_ENV += glib_cv_uscore=no
$(PKG)_CONFIGURE_ENV += glib_cv_long_long_format=11
$(PKG)_CONFIGURE_ENV += glib_cv_have_strlcpy=yes
$(PKG)_CONFIGURE_ENV += ac_cv_func_mmap_fixed=yes
$(PKG)_CONFIGURE_ENV += glib_cv_pcre_has_unicode=yes

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

$($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(GLIB2_DIR) \
		all

$($(PKG)_LIBS_STAGING_DIR): $($(PKG)_LIBS_BUILD_DIR)
	$(SUBMAKE) -C $(GLIB2_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(GLIB2_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib%-$(GLIB2_MAJOR_VERSION).la) \
		$(GLIB2_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/%-$(GLIB2_MAJOR_VERSION).pc) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/gmodule-no-export-$(GLIB2_MAJOR_VERSION).pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/gmodule-export-$(GLIB2_MAJOR_VERSION).pc

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_TARGET_DIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_LIBS_STAGING_DIR)

$(pkg)-precompiled: $($(PKG)_LIBS_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(GLIB2_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		uninstall
	-$(SUBMAKE) -C $(GLIB2_DIR) clean
	$(RM) -r \
		$(GLIB2_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib%-$(GLIB2_MAJOR_VERSION)*) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/glib-$(GLIB2_MAJOR_VERSION) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/glib-$(GLIB2_MAJOR_VERSION) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/glib-$(GLIB2_MAJOR_VERSION)

$(pkg)-uninstall:
	$(RM) $(GLIB2_LIBNAMES_SHORT:%=$(GLIB2_TARGET_DIR)/lib%-$(GLIB2_MAJOR_VERSION).so*)

$(PKG_FINISH)
