$(call PKG_INIT_LIB, 2.4.1)
$(PKG)_LIB_VERSION:=1.2.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://www.mpfr.org/mpfr-$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/libmpfr.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmpfr.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libmpfr.so.$($(PKG)_LIB_VERSION)
$(PKG)_SOURCE_MD5:=c5ee0a8ce82ad55fe29ac57edd35d09e

$(PKG)_DEPENDS_ON:= gmp

$(PKG)_CONFIGURE_OPTIONS += --with-gmp-build=$(TARGET_TOOLCHAIN_STAGING_DIR)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(MPFR_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		-C $(MPFR_DIR) install

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(MPFR_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmpfr.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/mpfr*.h

$(pkg)-uninstall:
#	$(RM) $(MPFR_TARGET_DIR)/libmpfr*.so*

$(PKG_FINISH)

# host version
MPFR_DIR2:=$(SOURCE_DIR)/mpfr-$(MPFR_VERSION)-host
MPFR_HOST_DIR:=$(FREETZ_BASE_DIR)/$(TOOLS_DIR)/build
MPFR_HOST_BINARY:=$(MPFR_HOST_DIR)/lib/libmpfr.a

$(MPFR_DIR2)/.configured: $(MPFR_DIR)/.unpacked $(GMP_HOST_BINARY)
	mkdir -p $(MPFR_DIR2)
	(cd $(MPFR_DIR2); rm -rf config.cache; \
		CC="$(TOOLS_CC)" \
		$(FREETZ_BASE_DIR)/$(MPFR_DIR)/configure \
		--prefix=/ \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--disable-shared \
		--enable-static \
		--with-gmp=$(GMP_HOST_DIR) \
		$(DISABLE_NLS) \
	)
	touch $@

$(MPFR_HOST_BINARY): $(MPFR_DIR2)/.configured
	$(SUBMAKE) DESTDIR=$(MPFR_HOST_DIR) -C $(MPFR_DIR2) install

host-libmpfr: $(MPFR_HOST_BINARY)
host-libmpfr-clean:
	rm -rf $(MPFR_HOST_DIR)
	-$(SUBMAKE) -C $(MPFR_DIR2) clean
host-libmpfr-dirclean:
	#rm -rf $(MPFR_HOST_DIR) $(MPFR_DIR2)
	rm -rf $(MPFR_DIR2)
