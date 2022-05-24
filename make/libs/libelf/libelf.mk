$(call PKG_INIT_LIB, 0.8.13)
$(PKG)_LIB_VERSION:=$($(PKG)_VERSION)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=591a9b4ec81c1f2042a97aa60564e0cb79d041c52faa7416acb38bc95bd2c76d
$(PKG)_SITE:=http://www.mr511.de/software

$(PKG)_BINARY:=$($(PKG)_DIR)/lib/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg).so.$($(PKG)_LIB_VERSION)

# recreate configure with a version of autoconf greater than 2.13 (we assume it's installed on build system)
$(PKG)_CONFIGURE_PRE_CMDS += autoconf --force;

$(PKG)_CONFIGURE_ENV += mr_cv_target_elf=yes
$(PKG)_CONFIGURE_ENV += libelf_cv_working_memmove=yes
$(PKG)_CONFIGURE_ENV += libelf_64bit=yes
$(PKG)_CONFIGURE_ENV += libelf_cv_struct_elf64_ehdr=yes
$(PKG)_CONFIGURE_ENV += libelf_cv_type_elf64_addr=no
$(PKG)_CONFIGURE_ENV += libelf_cv_struct_elf64_rel=yes

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-elf64=yes
$(PKG)_CONFIGURE_OPTIONS += --enable-compat

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBELF_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE1) -C $(LIBELF_DIR) \
		instroot="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libelf.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBELF_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libelf*

$(pkg)-uninstall:
	$(RM) $(LIBELF_TARGET_DIR)/libelf*.so*

$(PKG_FINISH)
