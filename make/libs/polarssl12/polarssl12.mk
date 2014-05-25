$(call PKG_INIT_LIB, 1.2.10)
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/polarssl-$($(PKG)_VERSION)
$(PKG)_SOURCE:=polarssl-$($(PKG)_VERSION)-gpl.tgz
$(PKG)_SOURCE_SHA1:=ff4a75581359fe5b01aa2910bb27168a8e31800b
$(PKG)_SITE:=http://polarssl.org/code/releases

$(PKG)_LIBNAME:=lib$(pkg).so.$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/library/$($(PKG)_LIBNAME)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_LIBNAME)

$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libpolarssl12_WITH_BLOWFISH
$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libpolarssl12_WITH_GENRSA

$(PKG)_SYMBOLS_TO_COMMENT_OUT += $(if $(FREETZ_LIB_libpolarssl12_WITH_BLOWFISH),,POLARSSL_BLOWFISH_C)
$(PKG)_SYMBOLS_TO_COMMENT_OUT += $(if $(FREETZ_LIB_libpolarssl12_WITH_GENRSA),,POLARSSL_GENPRIME)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
# Don't use -D/-U to define/undefine required symbols, patch config.h instead. The installed headers must contain properly defined symbols.
	$(if $(strip $(POLARSSL12_SYMBOLS_TO_COMMENT_OUT)), \
		for d in $(POLARSSL12_SYMBOLS_TO_COMMENT_OUT); do \
			$(SED) -ri -e "s|^([ \t]*#define[ \t]+$$d[ \t]*)$$|/* \1 */|" $(POLARSSL12_DIR)/include/polarssl/config.h; \
		done \
	)
	$(SUBMAKE) -C $(POLARSSL12_DIR)/library \
		VERSION="$(POLARSSL12_VERSION)" \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) $(FPIC) -I../include" \
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
