$(call TOOLS_INIT, 1.1.0)
$(PKG)_SOURCE:=mpc-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA1:=b019d9e1d27ec5fb99497159d43a3164995de2d0
$(PKG)_SITE:=@GNU/mpc

$(PKG)_DESTDIR:=$(HOST_TOOLS_DIR)
$(PKG)_BINARY:=$($(PKG)_DESTDIR)/lib/libmpc.a
$(PKG)_DEPENDS:=gmp-host mpfr-host


$(pkg)-source: $(DL_DIR)/$($(PKG)_SOURCE)
$(DL_DIR)/$($(PKG)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(MPC_HOST_SOURCE) $(MPC_HOST_SITE) $(MPC_HOST_SOURCE_SHA1)

$(TOOLS_UNPACKED)

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked $($(PKG)_DEPENDS:%-host=$($(PKG)_DESTDIR)/lib/lib%.a)
	(cd $(MPC_HOST_DIR); $(RM) config.cache; \
		CC="$(TOOLCHAIN_HOSTCC)" \
		CFLAGS="$(TOOLCHAIN_HOST_CFLAGS)" \
		./configure \
		--prefix=$(MPC_HOST_DESTDIR) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--disable-shared \
		--enable-static \
		--with-gmp=$(GMP_HOST_DESTDIR) \
		--with-mpfr=$(MPFR_HOST_DESTDIR) \
		$(DISABLE_NLS) \
		$(SILENT) \
	)
	touch $@

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured | $(HOST_TOOLS_DIR)
	$(TOOLS_SUBMAKE) -C $(MPC_HOST_DIR) install

$(pkg)-precompiled: $($(PKG)_BINARY)


$(pkg)-clean:
	-$(MAKE) -C $(MPC_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(MPC_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(MPC_HOST_DESTDIR)/lib/libmpc* $(MPC_HOST_DESTDIR)/include/*mpc*.h

$(TOOLS_FINISH)
