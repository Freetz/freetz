$(call PKG_INIT_LIB, 1.0.13)
$(PKG)_SOURCE:=$(pkg)_$($(PKG)_VERSION).orig.tar.gz
$(PKG)_SOURCE_MD5:=c1ba392ce61dc4aff1c29ea4e92f6df4
$(PKG)_SITE:=http://ftp.de.debian.org/debian/pool/main/libg/libgsm

$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/gsm-1.0-pl13

$(PKG)_BINARY:=$($(PKG)_DIR)/lib/$(pkg).so.$($(PKG)_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(pkg).so.$($(PKG)_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg).so.$($(PKG)_VERSION)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBGSM_DIR) \
		CC="$(TARGET_CC)" \
		CCFLAGS="-c -fPIC $(TARGET_CFLAGS)" \
		LD="$(TARGET_CC)" \
		AR="$(TARGET_AR)" \
		RANLIB="$(TARGET_RANLIB)" \
		all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	cp -a $(LIBGSM_DIR)/inc/gsm.h $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/
	$(INSTALL_LIBRARY_INCLUDE_STATIC)

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBGSM_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgsm.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/gsm.h

$(pkg)-uninstall:
	$(RM) $(LIBGSM_TARGET_DIR)/libgsm.so*

$(PKG_FINISH)
