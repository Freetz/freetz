MPFR_HOST_VERSION:=3.1.6
MPFR_HOST_SOURCE:=mpfr-$(MPFR_HOST_VERSION).tar.xz
MPFR_HOST_SOURCE_SHA256:=7a62ac1a04408614fccdc506e4844b10cf0ad2c2b1677097f8f35d3a1344a950
MPFR_HOST_SITE:=http://www.mpfr.org/mpfr-$(MPFR_HOST_VERSION)

MPFR_HOST_DIR:=$(TOOLS_SOURCE_DIR)/mpfr-$(MPFR_HOST_VERSION)
MPFR_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/mpfr-host
MPFR_HOST_DESTDIR:=$(HOST_TOOLS_DIR)
MPFR_HOST_BINARY:=$(MPFR_HOST_DESTDIR)/lib/libmpfr.a
MPFR_HOST_BINARY_DEPS:=gmp-host


mpfr-host-source: $(DL_DIR)/$(MPFR_HOST_SOURCE)
$(DL_DIR)/$(MPFR_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(MPFR_HOST_SOURCE) $(MPFR_HOST_SITE) $(MPFR_HOST_SOURCE_SHA256)

mpfr-host-unpacked: $(MPFR_HOST_DIR)/.unpacked
$(MPFR_HOST_DIR)/.unpacked: $(DL_DIR)/$(MPFR_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(MPFR_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(MPFR_HOST_MAKE_DIR)/patches,$(MPFR_HOST_DIR))
	touch $@

$(MPFR_HOST_DIR)/.configured: $(MPFR_HOST_DIR)/.unpacked $(MPFR_HOST_BINARY_DEPS:%-host=$(MPFR_HOST_DESTDIR)/lib/lib%.a)
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

$(MPFR_HOST_BINARY): $(MPFR_HOST_DIR)/.configured | $(HOST_TOOLS_DIR)
	$(TOOL_SUBMAKE) -C $(MPFR_HOST_DIR)/src install

mpfr-host-precompiled: $(MPFR_HOST_BINARY)


mpfr-host-clean:
	-$(MAKE) -C $(MPFR_HOST_DIR) clean

mpfr-host-dirclean:
	$(RM) -r $(MPFR_HOST_DIR)

mpfr-host-distclean: mpfr-host-dirclean
	$(RM) $(MPFR_HOST_DESTDIR)/lib/libmpfr* $(MPFR_HOST_DESTDIR)/include/*mpfr*.h

