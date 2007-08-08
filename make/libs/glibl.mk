GLIBL_VERSION:=2.12.12
GLIBL_LIB_VERSION:=0.1200.12
GLIBL_SOURCE:=glib-$(GLIBL_VERSION).tar.gz
GLIBL_SITE:=ftp://ftp.gtk.org/pub/glib/2.12
GLIBL_MAKE_DIR:=$(MAKE_DIR)/libs
GLIBL_DIR:=$(SOURCE_DIR)/glib-$(GLIBL_VERSION)
GLIBL_BINARY:=$(GLIBL_DIR)/glib/.libs/libglib-2.0.so.$(GLIBL_LIB_VERSION)
GLIBL_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libglib-2.0.so.$(GLIBL_LIB_VERSION)
GLIBL_TARGET_DIR:=root/usr/lib
GLIBL_TARGET_BINARY:=$(GLIBL_TARGET_DIR)/libglib-2.0.so.$(GLIBL_LIB_VERSION)

$(DL_DIR)/$(GLIBL_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(GLIBL_SITE)/$(GLIBL_SOURCE)

$(GLIBL_DIR)/.unpacked: $(DL_DIR)/$(GLIBL_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(GLIBL_SOURCE)
	for i in $(GLIBL_MAKE_DIR)/patches/*.glibl.patch; do \
		$(PATCH_TOOL) $(GLIBL_DIR) $$i; \
	done
	touch $@

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

$(GLIBL_BINARY): $(GLIBL_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(GLIBL_DIR)/glib \
		all

$(GLIBL_STAGING_BINARY): $(GLIBL_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(GLIBL_DIR)/glib \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install

$(GLIBL_TARGET_BINARY): $(GLIBL_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libglib-2.0.so* $(GLIBL_TARGET_DIR)/
	$(TARGET_STRIP) $@

glibl: $(GLIBL_STAGING_BINARY)

glibl-precompiled: uclibc gettext-precompiled libiconv-precompiled glibl $(GLIBL_TARGET_BINARY)

glibl-source: $(GLIBL_DIR)/.unpacked

glibl-clean:
	-$(MAKE) -C $(GLIBL_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libglib-2.0*

glibl-uninstall:
	rm -f $(GLIBL_TARGET_DIR)/libglib-2.0.so*

glibl-dirclean:
	rm -rf $(GLIBL_DIR)
