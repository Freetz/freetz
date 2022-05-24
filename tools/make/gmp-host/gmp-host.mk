$(call TOOLS_INIT, 6.1.2)
$(PKG)_SOURCE:=gmp-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=87b565e89a9a684fe4ebeeddb8399dce2599f9c9049854ca8c0dfbdea0e21912
$(PKG)_SITE:=@GNU/gmp

$(PKG)_DESTDIR:=$(HOST_TOOLS_DIR)
$(PKG)_BINARY:=$($(PKG)_DESTDIR)/lib/libgmp.a

$(PKG)_CONFIGURE_ENV += CC="$(TOOLCHAIN_HOSTCC)"
$(PKG)_CONFIGURE_ENV += CFLAGS="$(TOOLCHAIN_HOST_CFLAGS)"
$(PKG)_CONFIGURE_ENV += $(if $(strip $(FREETZ_TOOLCHAIN_32BIT)),ABI=32)

$(PKG)_CONFIGURE_OPTIONS += --prefix=$(GMP_HOST_DESTDIR)
$(PKG)_CONFIGURE_OPTIONS += --build=$(GNU_HOST_NAME)
$(PKG)_CONFIGURE_OPTIONS += --host=$(GNU_HOST_NAME)
$(PKG)_CONFIGURE_OPTIONS += --disable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)


$($(PKG)_BINARY): $($(PKG)_DIR)/.configured | $(HOST_TOOLS_DIR)
	$(TOOLS_SUBMAKE) -C $(GMP_HOST_DIR) install

$(pkg)-precompiled: $($(PKG)_BINARY)


$(pkg)-clean:
	-$(MAKE) -C $(GMP_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(GMP_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(GMP_HOST_DESTDIR)/lib/libgmp* $(GMP_HOST_DESTDIR)/include/gmp*.h

$(TOOLS_FINISH)
