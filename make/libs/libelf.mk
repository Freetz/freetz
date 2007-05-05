LIBELF_VERSION:=0.8.5
LIBELF_SOURCE:=libelf-$(LIBELF_VERSION).tar.gz
LIBELF_SITE:=http://www.mr511.de/software
LIBELF_DIR:=$(SOURCE_DIR)/libelf-$(LIBELF_VERSION)
LIBELF_MAKE_DIR:=$(MAKE_DIR)/libs

$(DL_DIR)/$(LIBELF_SOURCE):
	wget -P $(DL_DIR) $(LIBELF_SITE)/$(LIBELF_SOURCE)

$(LIBELF_DIR)/.unpacked: $(DL_DIR)/$(LIBELF_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(LIBELF_SOURCE)
#	for i in $(LIBELF_MAKE_DIR)/patches/*.libelf.patch; do \
#		patch -d $(LIBELF_DIR) -p0 < $$i; \
#	done
	touch $@

$(LIBELF_DIR)/.configured: $(LIBELF_DIR)/.unpacked
	( cd $(LIBELF_DIR); rm -f config.{cache,status} ; \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
		CFLAGS="$(TARGET_CFLAGS) -I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		LDSHARED="$(TARGET_CC) -static-libgcc" \
		mr_cv_target_elf=yes \
		libelf_64bit=yes \
		libelf_cv_struct_elf64_ehdr=yes \
		libelf_cv_type_elf64_addr=no \
		libelf_cv_struct_elf64_rel=yes \
		ac_cv_sizeof_long_long=8 \
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
		--enable-elf64=yes \
	);
	touch $@

$(LIBELF_DIR)/.compiled: $(LIBELF_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(LIBELF_DIR) -j1 \
		$(TARGET_CONFIGURE_OPTS) 
	touch $@

$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libelf.so: $(LIBELF_DIR)/.compiled
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(LIBELF_DIR) -j1 \
		instroot="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		all install
	touch -c $@

ifeq ($(strip $(DS_EXTERNAL_COMPILER)),y)
libelf libelf-precompiled:
	@echo 'External compiler used. Skipping libelf...'
	cp -a $(TARGET_MAKE_PATH)/../usr/lib/libelf*.so* root/usr/lib/
else
libelf: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libelf.so
libelf-precompiled: uclibc libelf
	$(TARGET_STRIP) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libelf*.so*
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libelf*.so* root/usr/lib/
endif

libelf-source: $(LIBELF_DIR)/.unpacked

libelf-clean:
	-$(MAKE) -C $(LIBELF_DIR) clean

libelf-install: libelf-precompiled

libelf-uninstall:
	rm -rf root/usr/lib/libelf*.so*
#	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) -C $(LIBLIBELF_DIR) instroot="$(TARGET_TOOLCHAIN_STAGING_DIR)" uninstall

libelf-dirclean:
#	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) -C $(LIBLIBELF_DIR) instroot="$(TARGET_TOOLCHAIN_STAGING_DIR)" uninstall
	rm -rf $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libelf*.so.*
	rm -rf $(LIBELF_DIR)

