$(call PKG_INIT_BIN, 1.5.1)
$(PKG)_UGLY_VERSION:=0.0.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://mesh.dl.sourceforge.net/sourceforge/jamvm
$(PKG)_BINARY:=$($(PKG)_DIR)/src/jamvm
$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/src/.libs/libjvm.so.$($(PKG)_UGLY_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/jamvm
$(PKG)_TARGET_LIB_BINARY:=$($(PKG)_DEST_DIR)/usr/lib/libjvm.so.$($(PKG)_UGLY_VERSION)
$(PKG)_SOURCE_MD5:=5a82751b50391eb092c906ce64f3b6bf

$(PKG)_DEPENDS_ON := zlib libffi-sable classpath

$(PKG)_CONFIGURE_OPTIONS += --enable-ffi
$(PKG)_CONFIGURE_OPTIONS += --disable-int-threading
$(PKG)_CONFIGURE_OPTIONS += --with-classpath-install-dir="/usr"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(JAMVM_DIR)/src

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_LIB_BINARY): $($(PKG)_LIB_BINARY)
	cp -a $(JAMVM_DIR)/src/.libs/libjvm*.so* $(JAMVM_DEST_DIR)/usr/lib
	$(TARGET_STRIP) $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_LIB_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(JAMVM_DIR) clean

$(pkg)-uninstall:
	$(RM) $(JAMVM_TARGET_BINARY)
	$(RM) $(JAMVM_DEST_DIR)/usr/lib/libjvm*.so*

$(PKG_FINISH)
