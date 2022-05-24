$(call PKG_INIT_LIB, 1.2.19)
$(PKG)_SOURCE:=polarssl-$($(PKG)_VERSION)-gpl.tgz
$(PKG)_HASH:=24cb1608a160101ead3c7240f35fc447fe7880cd60f7ed6c9db7a1d773ccd4b8
$(PKG)_SITE:=http://polarssl.org/code/releases

$(PKG)_LIBNAME:=lib$(pkg).so.$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/library/$($(PKG)_LIBNAME)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_LIBNAME)

$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libpolarssl12_WITH_BLOWFISH
$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libpolarssl12_WITH_GENRSA

# disable some features to reduce library size
$(PKG)_FEATURES_TO_DISABLE += POLARSSL_SELF_TEST
$(PKG)_FEATURES_TO_DISABLE += POLARSSL_CAMELLIA_C
$(PKG)_FEATURES_TO_DISABLE += POLARSSL_CERTS_C
$(PKG)_FEATURES_TO_DISABLE += POLARSSL_DEBUG_C
$(PKG)_FEATURES_TO_DISABLE += POLARSSL_PADLOCK_C
$(PKG)_FEATURES_TO_DISABLE += POLARSSL_XTEA_C
$(PKG)_FEATURES_TO_DISABLE += $(if $(FREETZ_LIB_libpolarssl12_WITH_BLOWFISH),,POLARSSL_BLOWFISH_C)
$(PKG)_FEATURES_TO_DISABLE += $(if $(FREETZ_LIB_libpolarssl12_WITH_GENRSA),,POLARSSL_GENPRIME)

# Don't use -D/-U to define/undefine required symbols, patch config.h instead. The installed headers must contain properly defined symbols.
$(PKG)_PATCH_POST_CMDS += $(SED) -ri $(foreach f,$(POLARSSL12_FEATURES_TO_DISABLE),-e 's|^([ \t]*$(_hash)define[ \t]+$(f)[ \t]*)$$$$|/* \1 */|') include/polarssl/config.h;

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(POLARSSL12_DIR)/library \
		VERSION="$(POLARSSL12_VERSION)" \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) $(FPIC) -I../include -ffunction-sections -fdata-sections" \
		OFLAGS="" \
		AR="$(TARGET_AR)" \
		shared static

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/polarssl12/
	cp -a $(POLARSSL12_DIR)/include/polarssl/* $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/polarssl12/
	cp -a $(POLARSSL12_DIR)/library/libpolarssl12.a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/
	$(INSTALL_LIBRARY)

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(POLARSSL12_DIR)/library clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpolarssl12* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/polarssl12/

$(pkg)-uninstall:
	$(RM) $(POLARSSL12_TARGET_DIR)/libpolarssl12.so*

$(PKG_FINISH)
