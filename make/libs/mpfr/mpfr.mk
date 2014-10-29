$(call PKG_INIT_LIB, 3.1.2)
$(PKG)_LIB_VERSION:=4.1.2
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_MD5:=e3d203d188b8fe60bb6578dd3152e05c
$(PKG)_SITE:=http://www.mpfr.org/mpfr-$($(PKG)_VERSION)

$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/libmpfr.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmpfr.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libmpfr.so.$($(PKG)_LIB_VERSION)

$(PKG)_DEPENDS_ON += gmp

# prevent configure from being regenerated (008-gmp6-compat contains all changes needed)
$(PKG)_PATCH_POST_CMDS += touch -t 200001010000.00 configure.ac;

$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-thread-safe
$(PKG)_CONFIGURE_OPTIONS += --with-gmp=$(TARGET_TOOLCHAIN_STAGING_DIR)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(MPFR_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(MPFR_DIR)/src \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmpfr.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(MPFR_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmpfr.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/*mpfr*.h

$(pkg)-uninstall:
	$(RM) $(MPFR_TARGET_DIR)/libmpfr*.so*

$(PKG_FINISH)

# host version
MPFR_DIR2:=$(TOOLS_SOURCE_DIR)/mpfr-$(MPFR_VERSION)
MPFR_HOST_DIR:=$(HOST_TOOLS_DIR)
MPFR_HOST_BINARY:=$(MPFR_HOST_DIR)/lib/libmpfr.a

$(MPFR_DIR2)/.configured: $(GMP_HOST_BINARY) | $(MPFR_DIR)/.unpacked
	mkdir -p $(MPFR_DIR2)
	(cd $(MPFR_DIR2); $(RM) config.cache; \
		CC="$(TOOLCHAIN_HOST_CC)" \
		CFLAGS="$(TOOLCHAIN_HOST_CFLAGS)" \
		$(FREETZ_BASE_DIR)/$(MPFR_DIR)/configure \
		--prefix=$(MPFR_HOST_DIR) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--disable-shared \
		--enable-static \
		--with-gmp=$(GMP_HOST_DIR) \
		$(DISABLE_NLS) \
	)
	touch $@

$(MPFR_HOST_BINARY): $(MPFR_DIR2)/.configured | $(HOST_TOOLS_DIR)
	PATH=$(TARGET_PATH) $(MAKE) -C $(MPFR_DIR2)/src install

host-libmpfr: $(MPFR_HOST_BINARY)

host-libmpfr-uninstall:
	$(RM) $(MPFR_HOST_DIR)/lib/libmpfr* $(MPFR_HOST_DIR)/include/*mpfr*.h

host-libmpfr-clean: host-libmpfr-uninstall
	-$(MAKE) -C $(MPFR_DIR2) clean

host-libmpfr-dirclean: host-libmpfr-uninstall
	$(RM) -r $(MPFR_DIR2)
