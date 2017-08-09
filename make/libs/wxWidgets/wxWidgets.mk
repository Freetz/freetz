$(call PKG_INIT_LIB, 2.8.12)
$(PKG)_MAJOR_VERSION:=2.8
$(PKG)_LIB_VERSION:=0.8.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=4103e37e277abeb8aee607b990c215c4
$(PKG)_SITE:=@SF/wxwindows

$(PKG)_LIBNAME:=libwx_baseu-$($(PKG)_MAJOR_VERSION).so.$($(PKG)_LIB_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/lib/$($(PKG)_LIBNAME)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_LIBNAME)

$(PKG)_DEPENDS_ON += $(STDCXXLIB)
$(PKG)_REBUILD_SUBOPTS += FREETZ_STDCXXLIB

$(PKG)_CONFIGURE_ENABLE_OPTIONS := \
	monolithic \
	shared \
	std_string \
	unicode

# TODO: disable more unnecessary features
$(PKG)_CONFIGURE_DISABLE_OPTIONS := \
	apple_ieee \
	backtrace \
	compat24 compat26 controls \
	dialupman \
	fontmap \
	geometry gui \
	intl ipc \
	mediactrl \
	ole \
	plugins \
	rpath \
	sound \
	threads

$(PKG)_CONFIGURE_WITHOUT_OPTIONS := \
	cocoa \
	directfb dmalloc \
	expat \
	gnomeprint gnomevfs gtk \
	hildon \
	libjpeg libmspack libpng libtiff libxpm \
	mac mgl microwin motif msw \
	odbc opengl \
	pm \
	regex \
	sdl subdirs \
	wine \
	x x11 \
	zlib

$(PKG)_CONFIGURE_OPTIONS += $(foreach option,$($(PKG)_CONFIGURE_ENABLE_OPTIONS),--enable-$(option))
$(PKG)_CONFIGURE_OPTIONS += $(foreach option,$($(PKG)_CONFIGURE_DISABLE_OPTIONS),--disable-$(option))
$(PKG)_CONFIGURE_OPTIONS += $(foreach option,$($(PKG)_CONFIGURE_WITHOUT_OPTIONS),--without-$(option))

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(WXWIDGETS_DIR) \
		HOST_SUFFIX=""

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(WXWIDGETS_DIR) \
		HOST_SUFFIX="" \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install_monolib_static \
		install
	$(SED) -i -r \
		-e 's,TARGET_TOOLCHAIN_STAGING_DIR_PLACEHOLDER,$(TARGET_TOOLCHAIN_STAGING_DIR),g' \
		-e 's,(wx_baseu-$(WXWIDGETS_MAJOR_VERSION))-$(TARGET_ARCH_ENDIANNESS_DEPENDENT)-linux,\1,g' \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/wx/config/*-$(WXWIDGETS_MAJOR_VERSION)

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(WXWIDGETS_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libwx_* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/wx/ \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/wx-config \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/wx-$(WXWIDGETS_MAJOR_VERSION) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/aclocal/wx* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/bakefile/presets/wx*

$(pkg)-uninstall:
	$(RM) $(WXWIDGETS_TARGET_DIR)/libwx_*.so*

$(PKG_FINISH)
