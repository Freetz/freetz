$(call PKG_INIT_LIB, 1.2.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=5aa77f55c0e0aab8eb8ed982335daac8
$(PKG)_SITE:=http://downloads.xiph.org/releases/vorbis

$(PKG)_LIBVERSIONS := 0.4.3 2.0.6 3.3.2
$(PKG)_LIBNAMES_SHORT := vorbis vorbisenc vorbisfile

# append .so.<version> to short library name 
# = libvorbis.so.0.4.3 libvorbisenc.so.2.0.6 libvorbisfile.3.3.2
$(PKG)_LIBNAMES_LONG :=  $(join $($(PKG)_LIBNAMES_SHORT:%=lib%.so.) ,$($(PKG)_LIBVERSIONS)) 

# list of build directory + library binary (like $(PKG)_BINARY in single binary packages)
# = source/libvorbis-1.2.3/lib/.libs/libvorbis.so.0.4.3 source/libvorbis-1.2.3/lib/.libs/libvorbisenc.so.2.0.6 source/libvorbis-1.2.3/lib/.libs/libvorbis.so.3.3.2
$(PKG)_LIBS_BUILD_DIR := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_DIR)/lib/.libs/%)

# list of staging directory + library binary (with TC=.../toolchain/build/gcc-4.2.4-uClibc-0.9.29/mipsel-linux-uclibc)
# = TC/usr/lib/libvorbis.so.0.4.3 TC/usr/lib/libvorbisenc.so.2.0.6 TC/usr/lib/libvorbis.so.3.3.2
$(PKG)_LIBS_STAGING_DIR := $($(PKG)_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)

# list of pathnames to the final library path (X=build/modified/filesystem)
# = root/usr/lib/libvorbis.so.0.4.3 root/usr/lib/libvorbisenc.so.2.0.6 root/usr/lib/libvorbis.so.3.3.2
$(PKG)_LIBS_TARGET_DIR := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_TARGET_DIR)/%)


$(PKG)_DEPENDS_ON := libogg

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --disable-dependency-tracking
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --with-ogg-libraries="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib"
$(PKG)_CONFIGURE_OPTIONS += --with-ogg-includes="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(LIBVORBIS_DIR) \
		all

$($(PKG)_LIBS_STAGING_DIR): $($(PKG)_LIBS_BUILD_DIR)
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(LIBVORBIS_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(LIBVORBIS_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib%.la) \
		$(LIBVORBIS_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/%.pc)


$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_TARGET_DIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_LIBS_STAGING_DIR)

$(pkg)-precompiled: $($(PKG)_LIBS_TARGET_DIR

$(pkg)-clean:
	-$(MAKE) -C $(LIBVORBIS_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		uninstall
	-$(MAKE) -C $(LIBVORBIS_DIR) clean
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/vorbis

$(pkg)-uninstall:
	$(RM) $(LIBVORBIS_TARGET_DIR)/libvorbis*.so*

$(PKG_FINISH)
