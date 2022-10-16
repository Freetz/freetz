$(call TOOLS_INIT, 3.1.6)
$(PKG)_SOURCE:=mpfr-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=7a62ac1a04408614fccdc506e4844b10cf0ad2c2b1677097f8f35d3a1344a950
$(PKG)_SITE:=http://www.mpfr.org/mpfr-$($(PKG)_VERSION)

$(PKG)_BINARY:=$(HOST_TOOLS_DIR)/lib/libmpfr.a
$(PKG)_DEPENDS_ON+=gmp-host

$(PKG)_CONFIGURE_ENV += CC="$(TOOLCHAIN_HOST_CC)"
$(PKG)_CONFIGURE_ENV += CFLAGS="$(TOOLCHAIN_HOST_CFLAGS)"

$(PKG)_CONFIGURE_OPTIONS += --prefix=$(HOST_TOOLS_DIR)
$(PKG)_CONFIGURE_OPTIONS += --build=$(GNU_HOST_NAME)
$(PKG)_CONFIGURE_OPTIONS += --host=$(GNU_HOST_NAME)
$(PKG)_CONFIGURE_OPTIONS += --disable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --with-gmp=$(HOST_TOOLS_DIR)


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured | $(HOST_TOOLS_DIR)
	$(TOOLS_SUBMAKE) -C $(MPFR_HOST_DIR)/src install

$(pkg)-precompiled: $($(PKG)_BINARY)


$(pkg)-clean:
	-$(MAKE) -C $(MPFR_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(MPFR_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(HOST_TOOLS_DIR)/lib/libmpfr* $(HOST_TOOLS_DIR)/include/*mpfr*.h

$(TOOLS_FINISH)
