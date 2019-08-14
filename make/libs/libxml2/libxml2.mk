$(call PKG_INIT_LIB, 2.9.9)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA256:=94fb70890143e3c6549f265cee93ec064c80a84c42ad0f23e85ee1fd6540a871
$(PKG)_SITE:=ftp://xmlsoft.org/$(pkg)

$(PKG)_LIBNAME:=$(pkg).so.$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/$($(PKG)_LIBNAME)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_LIBNAME)

$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libxml2_WITH_HTML

ifeq ($(strip $(FREETZ_TARGET_UCLIBC_0_9_28)),y)
$(PKG)_DEPENDS_ON += iconv
endif
$(PKG)_DEPENDS_ON += zlib

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static

$(PKG)_CONFIGURE_OPTIONS += --enable-rebuild-docs=no
$(PKG)_CONFIGURE_OPTIONS += --with-debug=no
$(PKG)_CONFIGURE_OPTIONS += --with-run-debug=no
$(PKG)_CONFIGURE_OPTIONS += --with-python=no

$(PKG)_CONFIGURE_OPTIONS += --with-iso8859x=no
$(PKG)_CONFIGURE_OPTIONS += --with-iconv=yes

$(PKG)_CONFIGURE_OPTIONS += --with-threads=yes
$(PKG)_CONFIGURE_OPTIONS += --with-zlib=yes
$(PKG)_CONFIGURE_OPTIONS += --with-readline=no

$(PKG)_CONFIGURE_OPTIONS += --with-minimum=yes
$(PKG)_CONFIGURE_OPTIONS += --with-http=yes
$(PKG)_CONFIGURE_OPTIONS += --with-ftp=yes
$(PKG)_CONFIGURE_OPTIONS += --with-c14n=yes
$(PKG)_CONFIGURE_OPTIONS += --with-catalog=no
$(PKG)_CONFIGURE_OPTIONS += --with-docbook=no
$(PKG)_CONFIGURE_OPTIONS += --with-html=$(if $(FREETZ_LIB_libxml2_WITH_HTML),yes,no)
$(PKG)_CONFIGURE_OPTIONS += --with-legacy=no		#deprecated APIs for compatibility
$(PKG)_CONFIGURE_OPTIONS += --with-lzma=no
$(PKG)_CONFIGURE_OPTIONS += --with-output=yes		#serialization support
$(PKG)_CONFIGURE_OPTIONS += --with-pattern=yes		#xmlPattern selection interface
$(PKG)_CONFIGURE_OPTIONS += --with-push=yes		#PUSH parser interfaces
$(PKG)_CONFIGURE_OPTIONS += --with-reader=yes		#xmlReader parsing interface
$(PKG)_CONFIGURE_OPTIONS += --with-regexps=yes		#Regular Expressions support
$(PKG)_CONFIGURE_OPTIONS += --with-sax1=yes		#old SAX1 interface
$(PKG)_CONFIGURE_OPTIONS += --with-schemas=yes		#Relax-NG and Schemas support
$(PKG)_CONFIGURE_OPTIONS += --with-schematron=no	#Schematron support
$(PKG)_CONFIGURE_OPTIONS += --with-tree=yes		#DOM like tree manipulation APIs
$(PKG)_CONFIGURE_OPTIONS += --with-valid=yes		#DTD validation support
$(PKG)_CONFIGURE_OPTIONS += --with-writer=yes		#xmlWriter saving interface
$(PKG)_CONFIGURE_OPTIONS += --with-xinclude=yes		#XInclude support
$(PKG)_CONFIGURE_OPTIONS += --with-xpath=yes		#XPATH support
$(PKG)_CONFIGURE_OPTIONS += --with-xptr=yes		#XPointer support
$(PKG)_CONFIGURE_OPTIONS += --with-modules=no		#dynamic modules support, note: this requires libdl

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBXML2_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		-C $(LIBXML2_DIR) install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libxml2.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/xml2-config \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libxml-2.0.pc
		ln -sf libxml2/libxml $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/libxml

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBXML2_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libxml2* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/xml2-config \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/libxml* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libxml-2.0.pc

$(pkg)-uninstall:
	$(RM) $(LIBXML2_TARGET_DIR)/libxml2*.so*

$(PKG_FINISH)
