$(call TOOL_INIT, 6.1.2)
$(TOOL)_SOURCE:=gmp-$($(TOOL)_VERSION).tar.xz
$(TOOL)_SOURCE_SHA256:=87b565e89a9a684fe4ebeeddb8399dce2599f9c9049854ca8c0dfbdea0e21912
$(TOOL)_SITE:=@GNU/gmp

$(TOOL)_DESTDIR:=$(HOST_TOOLS_DIR)
$(TOOL)_BINARY:=$($(TOOL)_DESTDIR)/lib/libgmp.a


$(tool)-source: $(DL_DIR)/$($(TOOL)_SOURCE)
$(DL_DIR)/$($(TOOL)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(GMP_HOST_SOURCE) $(GMP_HOST_SITE) $(GMP_HOST_SOURCE_SHA256)

$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(DL_DIR)/$($(TOOL)_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(GMP_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(GMP_HOST_MAKE_DIR)/patches,$(GMP_HOST_DIR))
	touch $@

$($(TOOL)_DIR)/.configured: $($(TOOL)_DIR)/.unpacked
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

$($(TOOL)_BINARY): $($(TOOL)_DIR)/.configured | $(HOST_TOOLS_DIR)
	$(TOOL_SUBMAKE) -C $(GMP_HOST_DIR) install

$(tool)-precompiled: $($(TOOL)_BINARY)


$(tool)-clean:
	-$(MAKE) -C $(GMP_HOST_DIR) clean

$(tool)-dirclean:
	$(RM) -r $(GMP_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean
	$(RM) $(GMP_HOST_DESTDIR)/lib/libgmp* $(GMP_HOST_DESTDIR)/include/gmp*.h

$(TOOL_FINISH)
