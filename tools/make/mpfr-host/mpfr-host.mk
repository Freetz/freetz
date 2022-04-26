$(call TOOL_INIT, 3.1.6)
$(TOOL)_SOURCE:=mpfr-$($(TOOL)_VERSION).tar.xz
$(TOOL)_SOURCE_SHA256:=7a62ac1a04408614fccdc506e4844b10cf0ad2c2b1677097f8f35d3a1344a950
$(TOOL)_SITE:=http://www.mpfr.org/mpfr-$($(TOOL)_VERSION)

$(TOOL)_DESTDIR:=$(HOST_TOOLS_DIR)
$(TOOL)_BINARY:=$($(TOOL)_DESTDIR)/lib/libmpfr.a
$(TOOL)_DEPENDS:=gmp-host


$(tool)-source: $(DL_DIR)/$($(TOOL)_SOURCE)
$(DL_DIR)/$($(TOOL)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(MPFR_HOST_SOURCE) $(MPFR_HOST_SITE) $(MPFR_HOST_SOURCE_SHA256)

$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(DL_DIR)/$($(TOOL)_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(MPFR_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(MPFR_HOST_MAKE_DIR)/patches,$(MPFR_HOST_DIR))
	touch $@

$($(TOOL)_DIR)/.configured: $($(TOOL)_DIR)/.unpacked $($(TOOL)_DEPENDS:%-host=$($(TOOL)_DESTDIR)/lib/lib%.a)
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

$($(TOOL)_BINARY): $($(TOOL)_DIR)/.configured | $(HOST_TOOLS_DIR)
	$(TOOL_SUBMAKE) -C $(MPFR_HOST_DIR)/src install

$(tool)-precompiled: $($(TOOL)_BINARY)


$(tool)-clean:
	-$(MAKE) -C $(MPFR_HOST_DIR) clean

$(tool)-dirclean:
	$(RM) -r $(MPFR_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean
	$(RM) $(MPFR_HOST_DESTDIR)/lib/libmpfr* $(MPFR_HOST_DESTDIR)/include/*mpfr*.h

$(TOOL_FINISH)
