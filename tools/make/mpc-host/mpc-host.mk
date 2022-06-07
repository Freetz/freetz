$(call TOOLS_INIT, 1.1.0)
$(PKG)_SOURCE:=mpc-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=6985c538143c1208dcb1ac42cedad6ff52e267b47e5f970183a3e75125b43c2e
$(PKG)_SITE:=@GNU/mpc

$(PKG)_BINARY:=$(HOST_TOOLS_DIR)/lib/libmpc.a
$(PKG)_DEPENDS+=gmp-host mpfr-host

$(PKG)_CONFIGURE_ENV += CC="$(TOOLCHAIN_HOSTCC)"
$(PKG)_CONFIGURE_ENV += CFLAGS="$(TOOLCHAIN_HOST_CFLAGS)"

$(PKG)_CONFIGURE_OPTIONS += --prefix=$(HOST_TOOLS_DIR)
$(PKG)_CONFIGURE_OPTIONS += --build=$(GNU_HOST_NAME)
$(PKG)_CONFIGURE_OPTIONS += --host=$(GNU_HOST_NAME)
$(PKG)_CONFIGURE_OPTIONS += --disable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --with-gmp=$(HOST_TOOLS_DIR)
$(PKG)_CONFIGURE_OPTIONS += --with-mpfr=$(HOST_TOOLS_DIR)


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured | $(HOST_TOOLS_DIR)
	$(TOOLS_SUBMAKE) -C $(MPC_HOST_DIR) install

$(pkg)-precompiled: $($(PKG)_BINARY)


$(pkg)-clean:
	-$(MAKE) -C $(MPC_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(MPC_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(HOST_TOOLS_DIR)/lib/libmpc* $(HOST_TOOLS_DIR)/include/*mpc*.h

$(TOOLS_FINISH)
