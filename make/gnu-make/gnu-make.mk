$(call PKG_INIT_BIN, 4.2.1)
$(PKG)_SOURCE:=make-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=15b012617e7c44c0ed482721629577ac
$(PKG)_SITE:=@GNU/make

$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/make-$($(PKG)_VERSION)

$(PKG)_BINARY:=$($(PKG)_DIR)/make
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/make

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_MAKE_AC_VARIABLES_PACKAGE_SPECIFIC,lib_elf_elf_begin struct_st_mtim_nsec)
$(PKG)_CONFIGURE_ENV += gnu_make_lib_elf_elf_begin=no

$(PKG)_CONFIGURE_ENV += make_cv_sys_gnu_glob=no
$(PKG)_CONFIGURE_ENV += GLOBINC='-Iglob/'
$(PKG)_CONFIGURE_ENV += GLOBLIB=glob/libglob.a

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(GNU_MAKE_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(GNU_MAKE_DIR) clean

$(pkg)-uninstall:
	$(RM) $(GNU_MAKE_TARGET_BINARY)

$(PKG_FINISH)
