$(call PKG_INIT_LIB, 1.3.3)
$(PKG)_LIB_VERSION:=3.0.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=6474e98851d9f6f33871957ddee9714fdcd9d8a5ee9abb5a98d63ea2e60e12f3
$(PKG)_SITE:=@SF/libtirpc
### WEBSITE:=https://sourceforge.net/projects/libtirpc/
### CHANGES:=http://git.linux-nfs.org/?p=steved/libtirpc.git;a=shortlog;h=refs/heads/master
### CVSREPO:=http://git.linux-nfs.org/?p=steved/libtirpc.git

$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libtirpc.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libtirpc.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --without-openldap
$(PKG)_CONFIGURE_OPTIONS += --disable-gssapi

$(PKG)_CFLAGS += -D_STRUCT_TIMESPEC


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBTIRPC_DIR) all \
		CFLAGS="$(TARGET_CFLAGS) $(LIBTIRPC_CFLAGS)"

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBTIRPC_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libtirpc.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBTIRPC_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libtirpc.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/tirpc/ \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libtirpc.pc

$(pkg)-uninstall:
	$(RM) $(LIBTIRPC_TARGET_DIR)/libtirpc.so*

$(PKG_FINISH)
