FFI-SABLE_VERSION:=3325
FFI-SABLE_SOURCE:=libffi-sable-$(FFI-SABLE_VERSION).tar.gz
FFI-SABLE_SITE:=http://ftp.iasi.roedu.net/mirrors/openwrt.org/sources
FFI-SABLE_DIR:=$(SOURCE_DIR)/libffi-sable-$(FFI-SABLE_VERSION)
FFI-SABLE_MAKE_DIR:=$(MAKE_DIR)/libs

$(DL_DIR)/$(FFI-SABLE_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(FFI-SABLE_SITE)/$(FFI-SABLE_SOURCE)

$(FFI-SABLE_DIR)/.unpacked: $(DL_DIR)/$(FFI-SABLE_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(FFI-SABLE_SOURCE)
#	for i in $(FFI-SABLE_MAKE_DIR)/patches/*.ffi-sable.patch; do \
#		patch -d $(FFI-SABLE_DIR) -p0 < $$i; \
#	done
	touch $@

$(FFI-SABLE_DIR)/.configured: $(FFI-SABLE_DIR)/.unpacked
	( cd $(FFI-SABLE_DIR); rm -f config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		CFLAGS="$(TARGET_CFLAGS) -I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDSHARED="$(TARGET_CC) -static-libgcc" \
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
		--disable-debug \
	);
	touch $@

$(FFI-SABLE_DIR)/.compiled: $(FFI-SABLE_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(FFI-SABLE_DIR) \
		$(TARGET_CONFIGURE_OPTS) 
	touch $@

$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libffi.so: $(FFI-SABLE_DIR)/.compiled
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(FFI-SABLE_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	touch -c $@

ifeq ($(strip $(DS_EXTERNAL_COMPILER)),y)
ffi-sable ffi-sable-precompiled:
	@echo 'External compiler used. Skipping libffi-sable...'
	cp -a $(TARGET_MAKE_PATH)/../usr/lib/libffi*.so* root/usr/lib/
else
ffi-sable: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libffi.so
ffi-sable-precompiled: uclibc ffi-sable
	$(TARGET_STRIP) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libffi*.so*
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libffi*.so* root/usr/lib/
endif

ffi-sable-source: $(FFI-SABLE_DIR)/.unpacked

ffi-sable-clean:
	-$(MAKE) -C $(FFI-SABLE_DIR) clean
	rm -rf $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libffi*
	rm -rf root/usr/lib/libffi*.so*

ffi-sable-dirclean:
	rm -rf $(FFI-SABLE_DIR)

