$(call TOOL_INIT, 1.1.0)
$(TOOL)_SOURCE:=mpc-$($(TOOL)_VERSION).tar.gz
$(TOOL)_SOURCE_SHA1:=b019d9e1d27ec5fb99497159d43a3164995de2d0
$(TOOL)_SITE:=@GNU/mpc

$(TOOL)_DESTDIR:=$(HOST_TOOLS_DIR)
$(TOOL)_BINARY:=$($(TOOL)_DESTDIR)/lib/libmpc.a
$(TOOL)_DEPENDS:=gmp-host mpfr-host


$(tool)-source: $(DL_DIR)/$($(TOOL)_SOURCE)
$(DL_DIR)/$($(TOOL)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(MPC_HOST_SOURCE) $(MPC_HOST_SITE) $(MPC_HOST_SOURCE_SHA1)

$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(DL_DIR)/$($(TOOL)_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(MPC_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(MPC_HOST_MAKE_DIR)/patches,$(MPC_HOST_DIR))
	touch $@

$($(TOOL)_DIR)/.configured: $($(TOOL)_DIR)/.unpacked $($(TOOL)_DEPENDS:%-host=$($(TOOL)_DESTDIR)/lib/lib%.a)
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

$($(TOOL)_BINARY): $($(TOOL)_DIR)/.configured | $(HOST_TOOLS_DIR)
	$(TOOL_SUBMAKE) -C $(MPC_HOST_DIR) install

$(tool)-precompiled: $($(TOOL)_BINARY)


$(tool)-clean:
	-$(MAKE) -C $(MPC_HOST_DIR) clean

$(tool)-dirclean:
	$(RM) -r $(MPC_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean
	$(RM) $(MPC_HOST_DESTDIR)/lib/libmpc* $(MPC_HOST_DESTDIR)/include/*mpc*.h

$(TOOL_FINISH)
