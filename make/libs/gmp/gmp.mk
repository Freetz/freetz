$(call PKG_INIT_LIB, 5.1.2)
$(PKG)_LIB_VERSION:=10.1.2
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_MD5:=06fe2ca164221c59ce74867155cfc1ac
$(PKG)_SITE:=@GNU/$(pkg)

$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/libgmp.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgmp.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libgmp.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_MAKE_AC_VARIABLES_PACKAGE_SPECIFIC,path_LDCXX,,lt)

$(PKG)_CONFIGURE_ENV += gmp_cv_func_vsnprintf=yes

$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --with-readline=no

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(GMP_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(GMP_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgmp.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(GMP_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgmp.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/gmp*.h

$(pkg)-uninstall:
	$(RM) $(GMP_TARGET_DIR)/libgmp*.so*

$(PKG_FINISH)

# host version
GMP_DIR2:=$(TOOLS_SOURCE_DIR)/gmp-$(GMP_VERSION)
GMP_HOST_DIR:=$(HOST_TOOLS_DIR)
GMP_HOST_BINARY:=$(GMP_HOST_DIR)/lib/libgmp.a

$(GMP_DIR2)/.configured: | $(GMP_DIR)/.unpacked
	mkdir -p $(GMP_DIR2)
	(cd $(GMP_DIR2); $(RM) -r config.cache; \
		CC="$(TOOLCHAIN_HOSTCC)" \
		CFLAGS="$(TOOLCHAIN_HOST_CFLAGS)" \
		$(if $(strip $(FREETZ_TOOLCHAIN_32BIT)),ABI=32) \
		$(FREETZ_BASE_DIR)/$(GMP_DIR)/configure \
		--prefix=$(GMP_HOST_DIR) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--disable-shared \
		--enable-static \
		$(DISABLE_NLS) \
	)
	touch $@

$(GMP_HOST_BINARY): $(GMP_DIR2)/.configured | $(HOST_TOOLS_DIR)
	PATH=$(TARGET_PATH) $(MAKE) -C $(GMP_DIR2) install

host-libgmp: $(GMP_HOST_BINARY)

host-libgmp-uninstall:
	$(RM) $(GMP_HOST_DIR)/lib/libgmp* $(GMP_HOST_DIR)/include/gmp*.h

host-libgmp-clean: host-libgmp-uninstall
	-$(MAKE) -C $(GMP_DIR2) clean

host-libgmp-dirclean: host-libgmp-uninstall
	$(RM) -r $(GMP_DIR2)
