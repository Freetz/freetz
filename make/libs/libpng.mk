LIBPNG_VERSION:=1.2.10
LIBPNG_LIB_VERSION:=0.10.0
LIBPNG_SOURCE:=libpng-$(LIBPNG_VERSION).tar.gz
LIBPNG_SITE:=http://oss.oetiker.ch/rrdtool/pub/libs/
LIBPNG_MAKE_DIR:=$(MAKE_DIR)/libs
LIBPNG_DIR:=$(SOURCE_DIR)/libpng-$(LIBPNG_VERSION)
LIBPNG_BINARY:=$(LIBPNG_DIR)/.libs/libpng12.so.$(LIBPNG_LIB_VERSION)
LIBPNG_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpng12.so.$(LIBPNG_LIB_VERSION)
LIBPNG_TARGET_DIR:=root/usr/lib
LIBPNG_TARGET_BINARY:=$(LIBPNG_TARGET_DIR)/libpng12.so.$(LIBPNG_LIB_VERSION)

$(DL_DIR)/$(LIBPNG_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(LIBPNG_SITE)/$(LIBPNG_SOURCE)

$(LIBPNG_DIR)/.unpacked: $(DL_DIR)/$(LIBPNG_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(LIBPNG_SOURCE)
	for i in $(LIBPNG_MAKE_DIR)/patches/*.libpng.patch; do \
		$(PATCH_TOOL) $(LIBPNG_DIR) $$i; \
	done
	touch $@

$(LIBPNG_DIR)/.configured: $(LIBPNG_DIR)/.unpacked
	( cd $(LIBPNG_DIR); rm -f config.{cache,status} ; \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
		CFLAGS="$(TARGET_CFLAGS) -I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		ac_cv_func_memcmp_working=yes \
		ac_cv_have_decl_malloc=yes \
		gl_cv_func_malloc_0_nonnull=yes \
		ac_cv_func_malloc_0_nonnull=yes \
		ac_cv_func_calloc_0_nonnull=yes \
		ac_cv_func_realloc_0_nonnull=yes \
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
		--with-zlib=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/ \
	);
	touch $@

$(LIBPNG_BINARY): $(LIBPNG_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) -C $(LIBPNG_DIR)

$(LIBPNG_STAGING_BINARY): $(LIBPNG_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) -C $(LIBPNG_DIR)\
	    DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
	    install
	$(SED) -i -e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libpng12.la
	$(SED) -i -e "s,^prefix=.*,prefix=\'$(TARGET_TOOLCHAIN_STAGING_DIR)\',g" \
		-e "s,^exec_prefix=.*,exec_prefix=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/usr\',g" \
		-e "s,^includedir=.*,includedir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/include/libpng12\',g" \
		-e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/libpng12-config


$(LIBPNG_TARGET_BINARY): $(LIBPNG_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpng*.so* $(LIBPNG_TARGET_DIR)/
	$(TARGET_STRIP) $@

libpng: $(LIBPNG_STAGING_BINARY)

libpng-precompiled: uclibc zlib-precompiled libpng $(LIBPNG_TARGET_BINARY)

libpng-source: $(LIBPNG_DIR)/.unpacked

libpng-clean:
	-$(MAKE) -C $(LIBPNG_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpng*

libpng-uninstall:
	rm -f $(LIBPNG_TARGET_DIR)/libpng*.so*

libpng-dirclean:
	rm -rf $(LIBPNG_DIR)
