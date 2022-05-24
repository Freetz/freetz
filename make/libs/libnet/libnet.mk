$(call PKG_INIT_LIB, 1.1.4)
$(PKG)_LIB_VERSION:=1.5.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=de98229d9eca00b66c26cb368e582901cf768456321703bc38235e3b347b512d
$(PKG)_SITE:=@SF/$(pkg)-dev

$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg).so.$($(PKG)_LIB_VERSION)

# evaluated by running test program on target platform
$(PKG)_CONFIGURE_ENV += ac_cv_libnet_endianess=$(if $(FREETZ_TARGET_ARCH_BE),big,lil)
$(PKG)_CONFIGURE_ENV += ac_cv_lbl_unaligned_fail=$(or $(if $(FREETZ_TARGET_ARCH_MIPS),no),$(if $(FREETZ_TARGET_ARCH_X86),yes),UNSUPPORTED_ARCH)
$(PKG)_CONFIGURE_ENV += libnet_cv_have_packet_socket=yes
$(PKG)_CONFIGURE_ENV += ac_cv_libnet_linux_procfs=yes
$(PKG)_CONFIGURE_ENV += CROSS_TOOLCHAIN_STAGING_DIR=$(TARGET_TOOLCHAIN_STAGING_DIR)

$(PKG)_CONFIGURE_OPTIONS += --with-pf_packet=yes

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBNET_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBNET_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libnet.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBNET_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libnet* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/libnet.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/libnet \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/libnet-config \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/share/man/man?/libnet*

$(pkg)-uninstall:
	$(RM) $(LIBNET_TARGET_DIR)/libnet*.so*

$(PKG_FINISH)
