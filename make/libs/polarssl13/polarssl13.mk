$(call PKG_INIT_LIB, 1.3.22)
$(PKG)_SOURCE:=mbedtls-$($(PKG)_VERSION)-gpl.tgz
$(PKG)_HASH:=ded041aa4acf9a3e4d0c85bf334b0860135da996e75afdcc3abf22f403d14457
$(PKG)_SITE:=http://polarssl.org/code/releases

$(PKG)_LIBNAME:=lib$(pkg).so.$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/library/$($(PKG)_LIBNAME)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_LIBNAME)

$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libpolarssl13_WITH_BLOWFISH
$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libpolarssl13_WITH_GENRSA

# disable some features to reduce library size
$(PKG)_FEATURES_TO_DISABLE += POLARSSL_SELF_TEST
$(PKG)_FEATURES_TO_DISABLE += POLARSSL_CAMELLIA_C
$(PKG)_FEATURES_TO_DISABLE += POLARSSL_CERTS_C
$(PKG)_FEATURES_TO_DISABLE += POLARSSL_DEBUG_C
$(PKG)_FEATURES_TO_DISABLE += POLARSSL_PADLOCK_C
$(PKG)_FEATURES_TO_DISABLE += POLARSSL_XTEA_C
$(PKG)_FEATURES_TO_DISABLE += $(if $(FREETZ_LIB_libpolarssl13_WITH_BLOWFISH),,POLARSSL_BLOWFISH_C)
$(PKG)_FEATURES_TO_DISABLE += $(if $(FREETZ_LIB_libpolarssl13_WITH_GENRSA),,POLARSSL_GENPRIME)

# Don't use -D/-U to define/undefine required symbols, patch config.h instead. The installed headers must contain properly defined symbols.
$(PKG)_PATCH_POST_CMDS += $(SED) -ri $(foreach f,$(POLARSSL13_FEATURES_TO_DISABLE),-e 's|^([ \t]*$(_hash)define[ \t]+$(f)[ \t]*)$$$$|/* \1 */|') include/polarssl/config.h;

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(POLARSSL13_DIR)/library \
		VERSION="$(POLARSSL13_VERSION)" \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) $(FPIC) -I../include -ffunction-sections -fdata-sections" \
		OFLAGS="" \
		AR="$(TARGET_AR)" \
		shared static

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/polarssl13/
	cp -a $(POLARSSL13_DIR)/include/polarssl/* $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/polarssl13/
	cp -a $(POLARSSL13_DIR)/library/libpolarssl13.a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/
	$(INSTALL_LIBRARY)

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(POLARSSL13_DIR)/library clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpolarssl13* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/polarssl13/

$(pkg)-uninstall:
	$(RM) $(POLARSSL13_TARGET_DIR)/libpolarssl13.so*

$(PKG_FINISH)
