PACKAGE_LC:=gettext
PACKAGE_UC:=GETTEXT
$(PACKAGE_UC)_VERSION:=0.16.1
$(PACKAGE_INIT_LIB)
$(PACKAGE_UC)_LIB_VERSION:=8.0.1
$(PACKAGE_UC)_SOURCE:=gettext-$($(PACKAGE_UC)_VERSION).tar.gz
$(PACKAGE_UC)_SITE:=ftp://ftp.gnu.org/gnu/gettext/
$(PACKAGE_UC)_BINARY:=$($(PACKAGE_UC)_DIR)/gettext-runtime/intl/.libs/libintl.so.$($(PACKAGE_UC)_LIB_VERSION)
$(PACKAGE_UC)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libintl.so.$($(PACKAGE_UC)_LIB_VERSION)
$(PACKAGE_UC)_TARGET_BINARY:=$($(PACKAGE_UC)_TARGET_DIR)/libintl.so.$($(PACKAGE_UC)_LIB_VERSION)

$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-shared
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-static
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-rpath
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-nls                   
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-java                 
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-native-java          
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-openmp         
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --with-included-gettext  
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --without-libintl-prefix 
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --without-libexpat-prefix
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --without-emacs          


$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)
$(PACKAGE_CONFIGURED_CONFIGURE)

# We only want libintl
$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(GETTEXT_DIR)/gettext-runtime/intl \
		all

$($(PACKAGE_UC)_STAGING_BINARY): $($(PACKAGE_UC)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(GETTEXT_DIR)/gettext-runtime/intl \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(SED) -i -e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libintl.la

$($(PACKAGE_UC)_TARGET_BINARY): $($(PACKAGE_UC)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libintl*.so* $(GETTEXT_TARGET_DIR)/
	$(TARGET_STRIP) $@

gettext: $($(PACKAGE_UC)_STAGING_BINARY)

gettext-precompiled: uclibc gettext $($(PACKAGE_UC)_TARGET_BINARY)

gettext-clean:
	-$(MAKE) -C $(GETTEXT_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgettext*
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libintl*

gettext-uninstall:
	rm -f $(GETTEXT_TARGET_DIR)/libintl*.so*

$(PACKAGE_FINI)