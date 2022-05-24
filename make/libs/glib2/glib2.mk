$(call PKG_INIT_LIB, 2.32.4)
$(PKG)_LIB_VERSION:=0.3200.4
$(PKG)_MAJOR_VERSION:=2.0
$(PKG)_SOURCE:=glib-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=a5d742a4fda22fb6975a8c0cfcd2499dd1c809b8afd4ef709bda4d11b167fae2
$(PKG)_SITE:=https://download.gnome.org/sources/glib/$(call GET_MAJOR_VERSION,$($(PKG)_VERSION)),ftp://ftp.gnome.org/pub/gnome/sources/glib/$(call GET_MAJOR_VERSION,$($(PKG)_VERSION))
### WEBSITE:=https://www.gtk.org/
### MANPAGE:=https://docs.gtk.org/glib/
### CHANGES:=https://gitlab.gnome.org/GNOME/glib/blob/main/NEWS
### CVSREPO:=https://gitlab.gnome.org/GNOME/glib

$(PKG)_LIBNAMES_SHORT := glib gobject gmodule gthread gio
$(PKG)_LIBNAMES_LONG := $($(PKG)_LIBNAMES_SHORT:%=lib%-$($(PKG)_MAJOR_VERSION).so.$($(PKG)_LIB_VERSION))
$(PKG)_LIBS_BUILD_DIR := $(join $($(PKG)_LIBNAMES_SHORT:%=$($(PKG)_DIR)/%/.libs/),$($(PKG)_LIBNAMES_LONG))
$(PKG)_LIBS_STAGING_DIR := $($(PKG)_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)
$(PKG)_LIBS_TARGET_DIR := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_TARGET_DIR)/%)

$(PKG)_PKGCONFIGS_SHORT := $($(PKG)_LIBNAMES_SHORT) gmodule-no-export gmodule-export gio-unix

$(PKG)_BUILD_PREREQ += glib-genmarshal
$(PKG)_BUILD_PREREQ_HINT := Hint: on Debian-like systems this binary is provided by the libglib2.0-dev package

$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG)_DEPENDS_ON += pcre libffi zlib

# NB: glib2 does require iconv-functions, see glib/gconvert.c
# The configure option "--with-libiconv=no" means
# "do use the implementation provided by C library", i.e. by uClibc.
# As freetz' builds of uClibc prior to and excluding 0.9.29 do not
# provide them, we must use an extra library - the gnu-libiconv.
ifeq ($(strip $(FREETZ_TARGET_UCLIBC_0_9_28)),y)
$(PKG)_DEPENDS_ON += iconv
$(PKG)_CONFIGURE_OPTIONS += --with-libiconv=gnu
else
$(PKG)_CONFIGURE_OPTIONS += --with-libiconv=no
endif

$(PKG)_CONFIGURE_ENV += glib_cv_stack_grows=no
$(PKG)_CONFIGURE_ENV += glib_cv_uscore=no
$(PKG)_CONFIGURE_ENV += glib_cv_long_long_format=11
$(PKG)_CONFIGURE_ENV += glib_cv_have_strlcpy=yes
$(PKG)_CONFIGURE_ENV += ac_cv_func_mmap_fixed=yes
$(PKG)_CONFIGURE_ENV += ac_cv_func_printf_unix98=yes
$(PKG)_CONFIGURE_ENV += ac_cv_func_vsnprintf_c99=yes
$(PKG)_CONFIGURE_ENV += glib_cv_pcre_has_unicode=yes

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-debug=no
$(PKG)_CONFIGURE_OPTIONS += --disable-mem-pools
$(PKG)_CONFIGURE_OPTIONS += --disable-rebuilds
$(PKG)_CONFIGURE_OPTIONS += --with-threads=posix
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk-doc
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk-doc-html
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk-doc-pdf
$(PKG)_CONFIGURE_OPTIONS += --disable-man
$(PKG)_CONFIGURE_OPTIONS += --disable-fam
$(PKG)_CONFIGURE_OPTIONS += --disable-gcov
$(PKG)_CONFIGURE_OPTIONS += --disable-included-printf
$(PKG)_CONFIGURE_OPTIONS += --disable-selinux
$(PKG)_CONFIGURE_OPTIONS += --disable-xattr
$(PKG)_CONFIGURE_OPTIONS += --disable-dtrace
$(PKG)_CONFIGURE_OPTIONS += --disable-systemtap
$(PKG)_CONFIGURE_OPTIONS += --with-pcre=system

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

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
		$(GLIB2_PKGCONFIGS_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/%-$(GLIB2_MAJOR_VERSION).pc)

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_TARGET_DIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_LIBS_STAGING_DIR)

$(pkg)-precompiled: $($(PKG)_LIBS_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(GLIB2_DIR) clean
	$(RM) -r \
		$(GLIB2_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib%-$(GLIB2_MAJOR_VERSION)*) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/glib-$(GLIB2_MAJOR_VERSION) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/gdbus-$(GLIB2_MAJOR_VERSION) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/gio \
		\
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/glib-$(GLIB2_MAJOR_VERSION) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/gio-unix-$(GLIB2_MAJOR_VERSION) \
		\
		$(GLIB2_PKGCONFIGS_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/%-$(GLIB2_MAJOR_VERSION).pc) \
		\
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/glib-* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/gio-* \
		\
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/glib-$(GLIB2_MAJOR_VERSION) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/aclocal/glib*

$(pkg)-uninstall:
	$(RM) $(GLIB2_LIBNAMES_SHORT:%=$(GLIB2_TARGET_DIR)/lib%-$(GLIB2_MAJOR_VERSION).so*)

$(PKG_FINISH)
