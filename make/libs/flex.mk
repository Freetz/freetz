$(call PKG_INIT_LIB, 2.5.35)
$(PKG)_LIB_VERSION:=$($(PKG)_VERSION)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://surfnet.dl.sourceforge.net/sourceforge/flex
$(PKG)_BINARY:=$($(PKG)_DIR)/libfl.a
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfl.a
#$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libfl.a
$(PKG)_SOURCE_MD5:=201d3f38758d95436cbc64903386de0b 

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)


$(FLEX_BINARY): $(FLEX_DIR)/.configured
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(FLEX_DIR)

$(FLEX_STAGING_BINARY): $(FLEX_BINARY)
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(FLEX_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	# Don't try to run mipsel flex on host
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/bin/flex

$(pkg)-precompiled: $(FLEX_STAGING_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(FLEX_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfl* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/fl* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/man/man1/flex.1

$(pkg)-uninstall:
	$(RM) $(FLEX_TARGET_DIR)/libfl*

$(PKG_FINISH)
