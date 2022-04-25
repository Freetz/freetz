GMP_HOST_VERSION:=6.1.2
GMP_HOST_SOURCE:=gmp-$(GMP_HOST_VERSION).tar.xz
GMP_HOST_SOURCE_SHA256:=87b565e89a9a684fe4ebeeddb8399dce2599f9c9049854ca8c0dfbdea0e21912
GMP_HOST_SITE:=@GNU/gmp

GMP_HOST_DIR:=$(TOOLS_SOURCE_DIR)/gmp-$(GMP_HOST_VERSION)
GMP_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/gmp-host
GMP_HOST_DESTDIR:=$(HOST_TOOLS_DIR)
GMP_HOST_BINARY:=$(GMP_HOST_DESTDIR)/lib/libgmp.a


gmp-host-source: $(DL_DIR)/$(GMP_HOST_SOURCE)
$(DL_DIR)/$(GMP_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(GMP_HOST_SOURCE) $(GMP_HOST_SITE) $(GMP_HOST_SOURCE_SHA256)

gmp-host-unpacked: $(GMP_HOST_DIR)/.unpacked
$(GMP_HOST_DIR)/.unpacked: $(DL_DIR)/$(GMP_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(GMP_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(GMP_HOST_MAKE_DIR)/patches,$(GMP_HOST_DIR))
	touch $@

$(GMP_HOST_DIR)/.configured: $(GMP_HOST_DIR)/.unpacked
	(cd $(GMP_HOST_DIR); $(RM) config.cache; \
		CC="$(TOOLCHAIN_HOSTCC)" \
		CFLAGS="$(TOOLCHAIN_HOST_CFLAGS)" \
		$(if $(strip $(FREETZ_TOOLCHAIN_32BIT)),ABI=32) \
		./configure \
		--prefix=$(GMP_HOST_DESTDIR) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--disable-shared \
		--enable-static \
		$(DISABLE_NLS) \
		$(SILENT) \
	)
	touch $@

$(GMP_HOST_BINARY): $(GMP_HOST_DIR)/.configured | $(HOST_TOOLS_DIR)
	$(TOOL_SUBMAKE) -C $(GMP_HOST_DIR) install

gmp-host-precompiled: $(GMP_HOST_BINARY)


gmp-host-clean:
	-$(MAKE) -C $(GMP_HOST_DIR) clean

gmp-host-dirclean:
	$(RM) -r $(GMP_HOST_DIR)

gmp-host-distclean: gmp-host-dirclean
	$(RM) $(GMP_HOST_DESTDIR)/lib/libgmp* $(GMP_HOST_DESTDIR)/include/gmp*.h

