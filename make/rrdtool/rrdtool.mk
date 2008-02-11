$(call PKG_INIT_BIN, 1.2.23)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://oss.oetiker.ch/rrdtool/pub/
$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/rrdtool
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/rrdtool
$(PKG)_LIB_VERSION:=2.0.10
$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/src/.libs/librrd.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/librrd.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/lib/librrd.so.$($(PKG)_LIB_VERSION)
$(PKG)_STARTLEVEL=40

$(PKG)_DEPENDS_ON := libpng freetype libart_lgpl zlib

$(PKG)_CONFIGURE_ENV += PKG_CONFIG_PATH="$(TARGET_MAKE_PATH)/../usr/lib/pkgconfig"
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

LIBART_CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include/libart-2.0"
FREETYPE_CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include/freetype2"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(RRDTOOL_DIR) all \
		CPPFLAGS="$(TARGET_CPPFLAGS) $(LIBART_CPPFLAGS) $(FREETYPE_CPPFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	cp -a $(RRDTOOL_DIR)/src/.libs/librrd.so* $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/librrd.so* $(RRDTOOL_DEST_DIR)/usr/lib
	$(TARGET_STRIP) $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_LIB_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(RRDTOOL_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/librrd.so*

$(pkg)-uninstall:
	$(RM) $(RRDTOOL_TARGET_BINARY)
	$(RM) $(RRDTOOL_DEST_DIR)/usr/lib/librrd.so*

$(PKG_FINISH)
