$(call PKG_INIT_BIN, 2.7p32)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=f2c6bf195d9574aafedb9ba5eb1ae33f884ac70fa980098c0da377feb1efe53a
$(PKG)_SITE:=@SF/owfs

# Library
$(PKG)_SHORT_VERSION:=2.7
$(PKG)_LIB_VERSION:=32.0.0
$(PKG)_LIB_SUFFIX := $($(PKG)_SHORT_VERSION).so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_BUILD_SUBDIR := src/c/.libs
$(PKG)_LIBNAMES := libow
$(PKG)_LIBS_BUILD_DIR := $(OWFS_LIBNAMES:%=$($(PKG)_DIR)/module/owlib/$(OWFS_LIB_BUILD_SUBDIR)/%-$(OWFS_LIB_SUFFIX))
$(PKG)_LIBS_TARGET_DIR := $(OWFS_LIBNAMES:%=$($(PKG)_DEST_LIBDIR)/%-$(OWFS_LIB_SUFFIX))

# Binaries
$(PKG)_BINARIES_ALL := owserver owfs owftpd owhttpd owpresent owdir owread owwrite
$(PKG)_BINARIES_ALL_PATH := .libs/owserver .libs/owfs .libs/owftpd .libs/owhttpd owpresent owdir owread owwrite
$(PKG)_BINARY_BUILD_SUBDIR := src/c
$(PKG)_BINARIES_SUBDIRS := owserver owfs owftpd owhttpd owshell owshell owshell owshell
$(PKG)_BINARIES := $($(PKG)_BINARIES_ALL)
$(PKG)_BINARIES_BUILD_DIR := $(join $(OWFS_BINARIES_SUBDIRS:%=$($(PKG)_DIR)/module/%/$(OWFS_BINARY_BUILD_SUBDIR)/),$(OWFS_BINARIES_ALL_PATH:%=%))
$(PKG)_BINARIES_TARGET_DIR := $(OWFS_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_DEPENDS_ON += libusb fuse

$(PKG)_REBUILD_SUBOPTS += $(LIBUSB_REBUILD_SUBOPTS)

$(call REPLACE_LIBTOOL,,src/scripts/install,)
# Note: Replacing libtool and specifying "--disable-shared" at the same time
# doesn't make any sense as replaced libtool is built with shared libraries enabled.
# If you really want only static libraries to be created and linked in
# then you have to make a local copy of replaced libtool and modify it
# so that it doesn't create shared libraries (i.e. set build_libtool_libs to no).
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-usb
$(PKG)_CONFIGURE_OPTIONS += --enable-owhttpd
$(PKG)_CONFIGURE_OPTIONS += --enable-owfs
$(PKG)_CONFIGURE_OPTIONS += --enable-owftpd
$(PKG)_CONFIGURE_OPTIONS += --enable-owserver
$(PKG)_CONFIGURE_OPTIONS += --disable-tai8570
$(PKG)_CONFIGURE_OPTIONS += --disable-thermocouple
$(PKG)_CONFIGURE_OPTIONS += --disable-i2c
$(PKG)_CONFIGURE_OPTIONS += --disable-ha7
$(PKG)_CONFIGURE_OPTIONS += --disable-ownet
$(PKG)_CONFIGURE_OPTIONS += --disable-owtap
$(PKG)_CONFIGURE_OPTIONS += --disable-owmon
$(PKG)_CONFIGURE_OPTIONS += --disable-swig
$(PKG)_CONFIGURE_OPTIONS += --disable-owperl
$(PKG)_CONFIGURE_OPTIONS += --disable-owphp
$(PKG)_CONFIGURE_OPTIONS += --disable-owpython
$(PKG)_CONFIGURE_OPTIONS += --disable-owtcl
$(PKG)_CONFIGURE_OPTIONS += --disable-parport
$(PKG)_CONFIGURE_OPTIONS += --disable-owside
$(PKG)_CONFIGURE_OPTIONS += --disable-owcapi
$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-zero
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --with-libusb-config="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/libusb-config"
$(PKG)_CONFIGURE_OPTIONS += --with-fuseinclude="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include"
$(PKG)_CONFIGURE_OPTIONS += --with-fuselib="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_LIBS_BUILD_DIR) $($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(OWFS_DIR)

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_DEST_LIBDIR)/%: $($(PKG)_DIR)/module/owlib/$(OWFS_LIB_BUILD_SUBDIR)/%
	$(INSTALL_LIBRARY_STRIP)

$(foreach binary,$($(PKG)_BINARIES_BUILD_DIR),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),/usr/bin)))

$(pkg):

$(pkg)-precompiled: $($(PKG)_LIBS_TARGET_DIR) $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(OWFS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(OWFS_LIBS_TARGET_DIR) $(OWFS_BINARIES_TARGET_DIR)

$(PKG_FINISH)
