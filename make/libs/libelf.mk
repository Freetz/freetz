PACKAGE_LC:=libelf
PACKAGE_UC:=LIBELF
$(PACKAGE_UC)_VERSION:=0.8.10
$(PACKAGE_INIT_LIB)
$(PACKAGE_UC)_LIB_VERSION:=$($(PACKAGE_UC)_VERSION)
$(PACKAGE_UC)_SOURCE:=libelf-$($(PACKAGE_UC)_VERSION).tar.gz
$(PACKAGE_UC)_SITE:=http://www.mr511.de/software
$(PACKAGE_UC)_BINARY:=$($(PACKAGE_UC)_DIR)/lib/libelf.so.$($(PACKAGE_UC)_LIB_VERSION)
$(PACKAGE_UC)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libelf.so.$($(PACKAGE_UC)_LIB_VERSION)
$(PACKAGE_UC)_TARGET_BINARY:=$($(PACKAGE_UC)_TARGET_DIR)/libelf.so.$($(PACKAGE_UC)_LIB_VERSION)

$(PACKAGE_UC)_CONFIGURE_PRE_CMDS += autoconf --force ;
$(PACKAGE_UC)_CONFIGURE_ENV += mr_cv_working_memmove=yes
$(PACKAGE_UC)_CONFIGURE_ENV += mr_cv_target_elf=yes
$(PACKAGE_UC)_CONFIGURE_ENV += libelf_64bit=yes
$(PACKAGE_UC)_CONFIGURE_ENV += libelf_cv_struct_elf64_ehdr=yes
$(PACKAGE_UC)_CONFIGURE_ENV += libelf_cv_type_elf64_addr=no
$(PACKAGE_UC)_CONFIGURE_ENV += libelf_cv_struct_elf64_rel=yes
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-shared
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-static
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-elf64=yes

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)
$(PACKAGE_CONFIGURED_CONFIGURE)

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LIBELF_DIR)

$($(PACKAGE_UC)_STAGING_BINARY): $($(PACKAGE_UC)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE1) \
		instroot="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		-C $(LIBELF_DIR) install
	$(SED) -i -e "s,^includedir=.*,includedir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/include\',g" \
			-e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" \
			$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libelf.pc

$($(PACKAGE_UC)_TARGET_BINARY): $($(PACKAGE_UC)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libelf*.so* $(LIBELF_TARGET_DIR)/
	$(TARGET_STRIP) $@

libelf: $($(PACKAGE_UC)_STAGING_BINARY)

libelf-precompiled: uclibc libelf $($(PACKAGE_UC)_TARGET_BINARY)

libelf-clean:
	-$(MAKE) -C $(LIBELF_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libelf*

libelf-uninstall:
	rm -f $(LIBELF_TARGET_DIR)/libelf*.so*

$(PACKAGE_FINI)
