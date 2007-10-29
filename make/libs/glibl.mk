PACKAGE_LC:=glibl
PACKAGE_UC:=GLIBL
$(PACKAGE_UC)_VERSION:=2.12.12
$(PACKAGE_INIT_LIB)
GLIBL_LIB_VERSION:=0.1200.12
GLIBL_SOURCE:=glib-$(GLIBL_VERSION).tar.gz
GLIBL_SITE:=ftp://ftp.gtk.org/pub/glib/2.12
GLIBL_DIR:=$(SOURCE_DIR)/glib-$(GLIBL_VERSION)
GLIBL_BINARY:=$(GLIBL_DIR)/glib/.libs/libglib-2.0.so.$(GLIBL_LIB_VERSION)
GLIBL_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libglib-2.0.so.$(GLIBL_LIB_VERSION)
GLIBL_TARGET_BINARY:=$(GLIBL_TARGET_DIR)/libglib-2.0.so.$(GLIBL_LIB_VERSION)

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)


$(GLIBL_DIR)/.configured: $(GLIBL_DIR)/.unpacked
	( cd $(GLIBL_DIR); rm -f config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		CC="$(TARGET_CROSS)gcc" \
		ac_cv_func_posix_getpwuid_r=no \
		glib_cv_stack_grows=no \
		glib_cv_uscore=no \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--program-prefix="" \
		--program-suffix="" \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--datadir=/usr/share \
		--includedir=/usr/include \
		--infodir=/usr/share/info \
		--libdir=/usr/lib \
		--libexecdir=/usr/lib \
		--localstatedir=/var \
		--mandir=/usr/share/man \
		--sbindir=/usr/sbin \
		--sysconfdir=/etc \
		$(DISABLE_NLS) \
		$(DISABLE_LARGEFILE) \
		--enable-shared \
		--enable-static \
		--with-gnu-ld \
	);
	touch $@

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(GLIBL_DIR)/glib \
		all

$(GLIBL_STAGING_BINARY): $(GLIBL_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(GLIBL_DIR)/glib \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(SED) -i -e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libglib-2.0.la

$(GLIBL_TARGET_BINARY): $(GLIBL_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libglib-2.0.so* $(GLIBL_TARGET_DIR)/
	$(TARGET_STRIP) $@

glibl: $(GLIBL_STAGING_BINARY)

glibl-precompiled: uclibc gettext-precompiled libiconv-precompiled glibl $(GLIBL_TARGET_BINARY)

glibl-clean:
	-$(MAKE) -C $(GLIBL_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libglib-2.0*

glibl-uninstall:
	rm -f $(GLIBL_TARGET_DIR)/libglib-2.0.so*

$(PACKAGE_FINI)
