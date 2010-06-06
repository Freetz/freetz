$(call PKG_INIT_LIB, 5.0.1)
$(PKG)_LIB_VERSION:=10.0.1
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://ftp.gnu.org/gnu/gmp
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/libgmp.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgmp.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libgmp.so.$($(PKG)_LIB_VERSION)
$(PKG)_SOURCE_MD5:=6bac6df75c192a13419dfd71d19240a7

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
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgmp.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/gmp*.h

$(pkg)-uninstall:
	$(RM) $(GMP_TARGET_DIR)/libgmp*.so*

$(PKG_FINISH)

# host version
GMP_DIR2:=$(TOOLS_SOURCE_DIR)/gmp-$(GMP_VERSION)
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
	$(SUBMAKE) DESTDIR=$(GMP_HOST_DIR) \
		-C $(GMP_DIR2) install

host-libgmp: $(GMP_HOST_BINARY)

host-libgmp-clean:
	rm -rf $(GMP_HOST_DIR)
	-$(SUBMAKE) -C $(GMP_DIR2) clean

host-libgmp-dirclean:
	#rm -rf $(GMP_HOST_DIR) $(GMP_DIR2)
	rm -rf $(GMP_DIR2)
