$(eval $(call PKG_INIT_LIB, 2.12.12))
$(PKG)_LIB_VERSION:=0.1200.12
$(PKG)_SOURCE:=glib-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=ftp://ftp.gtk.org/pub/glib/2.12
$(PKG)_DIR:=$(SOURCE_DIR)/glib-$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/glib/.libs/libglib-2.0.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libglib-2.0.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libglib-2.0.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_ENV += glib_cv_stack_grows=no
$(PKG)_CONFIGURE_ENV += glib_cv_uscore=no
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(GLIBL_DIR)/glib \
		all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(GLIBL_DIR)/glib \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(SED) -i -e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libglib-2.0.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libglib-2.0.so* $(GLIBL_TARGET_DIR)/
	$(TARGET_STRIP) $@

glibl: $($(PKG)_STAGING_BINARY)

glibl-precompiled: uclibc gettext-precompiled libiconv-precompiled glibl $($(PKG)_TARGET_BINARY)

glibl-clean:
	-$(MAKE) -C $(GLIBL_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libglib-2.0*

glibl-uninstall:
	rm -f $(GLIBL_TARGET_DIR)/libglib-2.0.so*

$(PKG_FINISH)
