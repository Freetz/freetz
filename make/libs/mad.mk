MAD_VERSION:=0.15.1b
MAD_SOURCE:=libmad-$(MAD_VERSION).tar.gz
MAD_SITE:=http://mesh.dl.sourceforge.net/sourceforge/mad
MAD_DIR:=$(SOURCE_DIR)/libmad-$(MAD_VERSION)
MAD_MAKE_DIR:=$(MAKE_DIR)/libs


$(DL_DIR)/$(MAD_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(MAD_SITE)/$(MAD_SOURCE)

$(MAD_DIR)/.unpacked: $(DL_DIR)/$(MAD_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(MAD_SOURCE)
#	for i in $(MAD_MAKE_DIR)/patches/*.mad.patch; do \
#		patch -d $(MAD_DIR) -p0 < $$i; \
#	done
	touch $@

$(MAD_DIR)/.configured: $(MAD_DIR)/.unpacked
	( cd $(MAD_DIR); rm -f config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		CFLAGS="$(TARGET_CFLAGS) -I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDSHARED="$(TARGET_CC) -static-libgcc" \
		ac_cv_c_bigendian=no \
		ac_cv_type_pid_t=yes \
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
		--disable-debugging \
		--enable-speed \
		--enable-fpm="mips" \
	);
	touch $@

$(MAD_DIR)/.compiled: $(MAD_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(MAD_DIR) \
		$(TARGET_CONFIGURE_OPTS) 
	touch $@

$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmad.so: $(MAD_DIR)/.compiled
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(MAD_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	touch -c $@

ifeq ($(strip $(DS_EXTERNAL_COMPILER)),y)
mad mad-precompiled:
	@echo 'External compiler used. Skipping libmad...'
	cp -a $(TARGET_MAKE_PATH)/../usr/lib/libmad*.so* root/usr/lib/
else
mad: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmad.so
mad-precompiled: uclibc mad
	$(TARGET_STRIP) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmad*.so*
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmad*.so* root/usr/lib/
endif

mad-source: $(MAD_DIR)/.unpacked

mad-clean:
	-$(MAKE) -C $(MAD_DIR) clean
	rm -rf $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmad*
	rm -rf root/usr/lib/libmad*.so.*
	

mad-dirclean:
	rm -rf $(MAD_DIR)

