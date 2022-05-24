$(call TOOLS_INIT, 3.1.6)
$(PKG)_SOURCE:=mpfr-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_SHA256:=7a62ac1a04408614fccdc506e4844b10cf0ad2c2b1677097f8f35d3a1344a950
$(PKG)_SITE:=http://www.mpfr.org/mpfr-$($(PKG)_VERSION)

$(PKG)_DESTDIR:=$(HOST_TOOLS_DIR)
$(PKG)_BINARY:=$($(PKG)_DESTDIR)/lib/libmpfr.a
$(PKG)_DEPENDS:=gmp-host


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked
	(cd $(MPFR_HOST_DIR); $(RM) config.cache; \
		CC="$(TOOLCHAIN_HOST_CC)" \
		CFLAGS="$(TOOLCHAIN_HOST_CFLAGS)" \
		./configure \
		--prefix=$(MPFR_HOST_DESTDIR) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--disable-shared \
		--enable-static \
		--with-gmp=$(GMP_HOST_DESTDIR) \
		$(DISABLE_NLS) \
		$(SILENT) \
	)
	touch $@

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured | $(HOST_TOOLS_DIR)
	$(TOOLS_SUBMAKE) -C $(MPFR_HOST_DIR)/src install

$(pkg)-precompiled: $($(PKG)_BINARY)


$(pkg)-clean:
	-$(MAKE) -C $(MPFR_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(MPFR_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(MPFR_HOST_DESTDIR)/lib/libmpfr* $(MPFR_HOST_DESTDIR)/include/*mpfr*.h

$(TOOLS_FINISH)
