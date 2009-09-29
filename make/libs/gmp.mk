$(call PKG_INIT_LIB, 4.2.4)
$(PKG)_LIB_VERSION:=3.4.4
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://ftp.gnu.org/gnu/gmp
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/libgmp.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgmp.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_USR_LIB)/libgmp.so.$($(PKG)_LIB_VERSION)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(GMP_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_PATH) \
		$(MAKE) DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		-C $(GMP_DIR) install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgmp.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	mkdir -p $(GMP_DEST_USR_LIB)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgmp*.so* $(GMP_DEST_USR_LIB)/
	$(TARGET_STRIP) $@

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(GMP_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgmp.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/gmp*.h

$(pkg)-uninstall:
#	$(RM) $(GMP_TARGET_DIR)/libgmp*.so*

$(PKG_FINISH)

# host version
GMP_DIR2:=$(SOURCE_DIR)/gmp-$(GMP_VERSION)-host
GMP_HOST_DIR:=$(FREETZ_BASE_DIR)/$(TOOLS_DIR)/build
GMP_HOST_BINARY:=$(GMP_HOST_DIR)/lib/libgmp.a

$(GMP_DIR2)/.configured: $(GMP_DIR)/.unpacked
	mkdir -p $(GMP_DIR2)
	(cd $(GMP_DIR2); rm -rf config.cache; \
		CC="$(TOOLS_CC)" \
		$(FREETZ_BASE_DIR)/$(GMP_DIR)/configure \
		--prefix=/ \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--disable-shared \
		--enable-static \
		$(DISABLE_NLS) \
	)
	touch $@

$(GMP_HOST_BINARY): $(GMP_DIR2)/.configured
	$(MAKE) DESTDIR=$(GMP_HOST_DIR) \
		-C $(GMP_DIR2) install

host-libgmp: $(GMP_HOST_BINARY)

host-libgmp-clean:
	rm -rf $(GMP_HOST_DIR)
	-$(MAKE) -C $(GMP_DIR2) clean

host-libgmp-dirclean:
	#rm -rf $(GMP_HOST_DIR) $(GMP_DIR2)
	rm -rf $(GMP_DIR2)
