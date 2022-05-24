$(call PKG_INIT_LIB, 0.1.4)
$(PKG)_LIB_VERSION:=2.0.2
$(PKG)_SOURCE:=yaml-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=7bf81554ae5ab2d9b6977da398ea789722e0db75b86bffdaeb4e66d961de6a37
$(PKG)_SITE:=http://pyyaml.org/download/libyaml/

$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/libyaml-0.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libyaml-0.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libyaml-0.so.$($(PKG)_LIB_VERSION)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(YAML_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(YAML_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libyaml.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/yaml*.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(YAML_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libyaml*.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/yaml.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/yaml*.pc

$(pkg)-uninstall:
	$(RM) $(YAML_TARGET_DIR)/libyaml*.so*

$(PKG_FINISH)
