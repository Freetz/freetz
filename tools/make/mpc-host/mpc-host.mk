MPC_HOST_VERSION:=1.1.0
MPC_HOST_SOURCE:=mpc-$(MPC_HOST_VERSION).tar.gz
MPC_HOST_SOURCE_SHA1:=b019d9e1d27ec5fb99497159d43a3164995de2d0
MPC_HOST_SITE:=@GNU/mpc

MPC_HOST_DIR:=$(TOOLS_SOURCE_DIR)/mpc-$(MPC_HOST_VERSION)
MPC_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/mpc-host
MPC_HOST_DESTDIR:=$(HOST_TOOLS_DIR)
MPC_HOST_BINARY:=$(MPC_HOST_DESTDIR)/lib/libmpc.a
MPC_HOST_BINARY_DEPS:=gmp-host mpfr-host


mpc-host-source: $(DL_DIR)/$(MPC_HOST_SOURCE)
$(DL_DIR)/$(MPC_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(MPC_HOST_SOURCE) $(MPC_HOST_SITE) $(MPC_HOST_SOURCE_SHA1)

mpc-host-unpacked: $(MPC_HOST_DIR)/.unpacked
$(MPC_HOST_DIR)/.unpacked: $(DL_DIR)/$(MPC_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(MPC_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(MPC_HOST_MAKE_DIR)/patches,$(MPC_HOST_DIR))
	touch $@

$(MPC_HOST_DIR)/.configured: $(MPC_HOST_DIR)/.unpacked $(MPC_HOST_BINARY_DEPS:%-host=$(MPC_HOST_DESTDIR)/lib/lib%.a)
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

$(MPC_HOST_BINARY): $(MPC_HOST_DIR)/.configured | $(HOST_TOOLS_DIR)
	$(MAKE) -C $(MPC_HOST_DIR) install $(SILENT)

mpc-host-precompiled: $(MPC_HOST_BINARY)


mpc-host-clean:
	-$(MAKE) -C $(MPC_HOST_DIR) clean

mpc-host-dirclean:
	$(RM) -r $(MPC_HOST_DIR)

mpc-host-distclean: mpc-host-dirclean
	$(RM) $(MPC_HOST_DESTDIR)/lib/libmpc* $(MPC_HOST_DESTDIR)/include/*mpc*.h

