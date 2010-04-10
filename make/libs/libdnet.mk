$(call PKG_INIT_LIB, 1.12)
$(PKG)_LIB_VERSION:=1.0.1
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tgz
$(PKG)_SOURCE_MD5:=9253ef6de1b5e28e9c9a62b882e44cc9
$(PKG)_SITE:=http://libdnet.googlecode.com/files

$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg).so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --with-python=no
$(PKG)_CONFIGURE_OPTIONS += --with-wpdpack=no
$(PKG)_CONFIGURE_OPTIONS += --with-check=no

# NB: libtool shipped with libdnet is broken
# it defines shared_ext (later used in soname_spec and lib) to be the value of shrext_cmds, which is however never defined
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_CONFIGURE_PRE_CMDS += $(SED) -i -r -e "s,(shrext=('[$$$$]shrext')),\1\nshrext_cmds=\2,g;" ./configure;
# better/preferred solution, to be used as soon as automake-1.10 related libtool-host problems are solved
#$(call REPLACE_LIBTOOL)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBDNET_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBDNET_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libdnet.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/dnet-config

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBDNET_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libdnet* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/dnet \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/dnet.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/dnet-config \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/sbin/dnet

$(pkg)-uninstall:
	$(RM) $(LIBDNET_TARGET_DIR)/libdnet*

$(PKG_FINISH)
