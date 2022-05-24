$(call PKG_INIT_BIN, 1.2.30)
$(PKG)_LIBRRD_VERSION:=2.0.15
$(PKG)_LIBRRD_TH_VERSION:=2.0.13
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=3190efea410a6dd035799717948b2df09910f608d72d23ee81adad4cd0184ae9
$(PKG)_SITE:=https://oss.oetiker.ch/rrdtool/pub/archive
### WEBSITE:=https://www.rrdtool.org
### MANPAGE:=https://oss.oetiker.ch/rrdtool/doc
### CHANGES:=https://github.com/oetiker/rrdtool-1.x/blob/master/CHANGES
### CVSREPO:=https://github.com/oetiker/rrdtool-1.x

$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/rrdtool
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/rrdtool

$(PKG)_LIBS_SELECTED:=librrd.so.$($(PKG)_LIBRRD_VERSION)
ifeq ($(strip $(FREETZ_LIB_librrd_th)),y)
$(PKG)_LIBS_SELECTED+=librrd_th.so.$($(PKG)_LIBRRD_TH_VERSION)
endif
$(PKG)_LIBS_BUILD_DIR:=$($(PKG)_LIBS_SELECTED:%=$($(PKG)_DIR)/src/.libs/%)
$(PKG)_LIBS_STAGING_DIR:=$($(PKG)_LIBS_SELECTED:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)
$(PKG)_LIBS_TARGET_DIR:=$($(PKG)_LIBS_SELECTED:%=$($(PKG)_TARGET_LIBDIR)/%)

$(PKG)_DEPENDS_ON += libpng freetype libart_lgpl zlib

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_ENV += ac_cv_func_setpgrp_void=yes
$(PKG)_CONFIGURE_ENV += rd_cv_ieee_works=yes

$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/mod/etc
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --enable-rrdcgi
$(PKG)_CONFIGURE_OPTIONS += --disable-mmap
$(PKG)_CONFIGURE_OPTIONS += --disable-python
$(PKG)_CONFIGURE_OPTIONS += --disable-perl
$(PKG)_CONFIGURE_OPTIONS += --disable-tcl
$(PKG)_CONFIGURE_OPTIONS += --disable-ruby
$(PKG)_CONFIGURE_OPTIONS += --without-x

$(PKG)_LIBART_CPPFLAGS:="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/libart-2.0"
$(PKG)_FREETYPE_CPPFLAGS:="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/freetype2"


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(RRDTOOL_DIR) all \
		CPPFLAGS="$(TARGET_CPPFLAGS) $(RRDTOOL_LIBART_CPPFLAGS) $(RRDTOOL_FREETYPE_CPPFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIBS_STAGING_DIR): $($(PKG)_LIBS_BUILD_DIR)
	$(SUBMAKE) -C $(RRDTOOL_DIR)/src \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install-includeHEADERS \
		install-libLTLIBRARIES
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/librrd.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/librrd_th.la

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_TARGET_LIBDIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_LIBS_TARGET_DIR)


$(pkg)-clean:
	-$(SUBMAKE) -C $(RRDTOOL_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/librrd* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/rrd.h

$(pkg)-uninstall:
	$(RM) $(RRDTOOL_TARGET_BINARY)
	$(RM) $(RRDTOOL_TARGET_LIBDIR)/librrd*.so*

$(PKG_FINISH)

