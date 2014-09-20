$(call PKG_INIT_LIB, 1.7.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=b80faff3e389000b9a161dda4812112d
$(PKG)_SITE:=http://downloads.openwrt.org/sources
$(PKG)_DIR:=$(subst -$($(PKG)_VERSION),,$($(PKG)_DIR))

$(PKG)_BINARY:=$($(PKG)_DIR)/src/libmatrixssl.so
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmatrixssl.so
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libmatrixssl.so

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(MATRIXSSL_DIR)/src \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) $(FPIC) -DLINUX -ffunction-sections -fdata-sections" \
		LDFLAGS="-pthread" \
		AR="$(TARGET_AR)" \
		RANLIB="$(TARGET_RANLIB)" \
		STRIP="$(TARGET_STRIP)"

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/{include/matrixSsl,lib}
# install headers and convert all local #include's within them to the global ones
	for f in matrixSsl.h matrixCommon.h src/matrixConfig.h; do \
		cat $(MATRIXSSL_DIR)/$$f | $(SED) -r -e 's,(#include[ \t]+)"([^"]+/)?([^"/]+)",\1<matrixSsl/\3>,g' \
		> $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/matrixSsl/$$(basename $$f); \
	done
	ln -sf matrixSsl/matrixSsl.h $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/matrixSsl.h
# install libraries
	cp $(MATRIXSSL_DIR)/src/libmatrixsslstatic.a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/
	$(INSTALL_LIBRARY_STRIP)

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(MATRIXSSL_DIR)/src clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmatrixssl* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/matrixSsl*

$(pkg)-uninstall:
	$(RM) $(MATRIXSSL_TARGET_DIR)/libmatrixssl*.so*

$(PKG_FINISH)
