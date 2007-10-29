PACKAGE_LC:=libelf
PACKAGE_UC:=LIBELF
$(PACKAGE_UC)_VERSION:=0.8.9
$(PACKAGE_INIT_LIB)
LIBELF_LIB_VERSION:=$(LIBELF_VERSION)
LIBELF_SOURCE:=libelf-$(LIBELF_VERSION).tar.gz
LIBELF_SITE:=http://www.mr511.de/software
LIBELF_BINARY:=$(LIBELF_DIR)/lib/libelf.so.$(LIBELF_LIB_VERSION)
LIBELF_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libelf.so.$(LIBELF_LIB_VERSION)
LIBELF_TARGET_BINARY:=$(LIBELF_TARGET_DIR)/libelf.so.$(LIBELF_LIB_VERSION)

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)


$(LIBELF_DIR)/.configured: $(LIBELF_DIR)/.unpacked
	( cd $(LIBELF_DIR); rm -f config.{cache,status} ; \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
		CFLAGS="$(TARGET_CFLAGS) -I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		mr_cv_working_memmove=yes \
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

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LIBELF_DIR)

$(LIBELF_STAGING_BINARY): $(LIBELF_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE1) \
		instroot="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		-C $(LIBELF_DIR) install
	$(SED) -i -e "s,^includedir=.*,includedir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/include\',g" \
			-e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" \
			$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libelf.pc

$(LIBELF_TARGET_BINARY): $(LIBELF_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libelf*.so* $(LIBELF_TARGET_DIR)/
	$(TARGET_STRIP) $@

libelf: $(LIBELF_STAGING_BINARY)

libelf-precompiled: uclibc libelf $(LIBELF_TARGET_BINARY)

libelf-clean:
	-$(MAKE) -C $(LIBELF_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libelf*

libelf-uninstall:
	rm -f $(LIBELF_TARGET_DIR)/libelf*.so*

$(PACKAGE_FINI)
