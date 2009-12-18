$(call PKG_INIT_LIB, 1.13.1)
$(PKG)_LIB_VERSION:=2.5.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=7ab33ebd26687c744a37264a330bbe9a
$(PKG)_SITE:=http://ftp.gnu.org/pub/gnu/libiconv
ifeq ($(strip $(FREETZ_TARGET_UCLIBC_VERSION_0_9_28)),y)
$(PKG)_PREFIX:=/usr
else
$(PKG)_PREFIX:=/usr/lib/$(pkg)
endif
$(PKG)_BINARY:=$($(PKG)_DIR)/lib/.libs/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)$($(PKG)_PREFIX)/lib/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg).so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --enable-relocatable

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(LIBICONV_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)$(LIBICONV_PREFIX)/{include,lib}
	cp -a $(LIBICONV_DIR)/include/iconv.h.inst $(TARGET_TOOLCHAIN_STAGING_DIR)$(LIBICONV_PREFIX)/include/iconv.h
	chmod 644 $(TARGET_TOOLCHAIN_STAGING_DIR)$(LIBICONV_PREFIX)/include/iconv.h
	cat $(LIBICONV_DIR)/lib/libiconv.la \
		| sed -r -e 's,^(installed=)no,\1yes,g' -e "s,^(libdir=)'.*',\1'$(LIBICONV_PREFIX)/lib',g" \
		> $(TARGET_TOOLCHAIN_STAGING_DIR)$(LIBICONV_PREFIX)/lib/libiconv.la
	chmod 755 $(TARGET_TOOLCHAIN_STAGING_DIR)$(LIBICONV_PREFIX)/lib/libiconv.la
	$(PKG_FIX_LIBTOOL_LA) $(TARGET_TOOLCHAIN_STAGING_DIR)$(LIBICONV_PREFIX)/lib/libiconv.la
	cp -a $(LIBICONV_DIR)/lib/.libs/libiconv.{a,so*} $(TARGET_TOOLCHAIN_STAGING_DIR)$(LIBICONV_PREFIX)/lib/

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(LIBICONV_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)$(LIBICONV_PREFIX)/lib/libiconv* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)$(LIBICONV_PREFIX)/include/iconv.h

$(pkg)-uninstall:
	$(RM) $(LIBICONV_TARGET_DIR)/libiconv*.so*

$(PKG_FINISH)
