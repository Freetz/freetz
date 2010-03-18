$(call PKG_INIT_BIN, 2.7p7)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=4c189f64a1a6110bef19639a36c3b0e1
$(PKG)_SITE:=@SF/owfs

$(PKG)_BINARY:=$($(PKG)_DIR)/module/owhttpd/src/c/.libs/owhttpd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/owhttpd

# Library
$(PKG)_SHORT_VERSION:=2.7
$(PKG)_LIB_VERSION:=7.0.0
$(PKG)_LIB_SUFFIX := $($(PKG)_SHORT_VERSION).so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_BUILD_SUBDIR := src/c/.libs
$(PKG)_LIBNAMES := libow
$(PKG)_LIBS_BUILD_DIR := $(OWFS_LIBNAMES:%=$($(PKG)_DIR)/module/owlib/$(OWFS_LIB_BUILD_SUBDIR)/%-$(OWFS_LIB_SUFFIX))
$(PKG)_LIBS_TARGET_DIR := $(OWFS_LIBNAMES:%=$($(PKG)_DEST_DIR)/usr/lib/%-$(OWFS_LIB_SUFFIX))

# Binaries
$(PKG)_BINARIES_ALL := owdir owfs owftpd owhttpd owpresent owread owwrite
$(PKG)_BINARIES_ALL_PATH := owdir .libs/owfs .libs/owftpd .libs/owhttpd owpresent owread owwrite
$(PKG)_BINARY_BUILD_SUBDIR := src/c
$(PKG)_BINARIES_SUBDIRS := owshell owfs owftpd owhttpd owshell owshell owshell
$(PKG)_BINARIES := $($(PKG)_BINARIES_ALL)
$(PKG)_BINARIES_BUILD_DIR := $(join $(OWFS_BINARIES_SUBDIRS:%=$($(PKG)_DIR)/module/%/$(OWFS_BINARY_BUILD_SUBDIR)/),$(OWFS_BINARIES_ALL_PATH:%=%))
$(PKG)_BINARIES_TARGET_DIR := $(OWFS_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

#$(PKG)_NOT_INCLUDED := $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

$(PKG)_DEPENDS_ON := libusb

$(call REPLACE_LIBTOOL)

$(PKG)_CONFIGURE_OPTIONS += --enable-usb
$(PKG)_CONFIGURE_OPTIONS += --disable-tai8570
$(PKG)_CONFIGURE_OPTIONS += --disable-thermocouple
$(PKG)_CONFIGURE_OPTIONS += --disable-i2c
$(PKG)_CONFIGURE_OPTIONS += --disable-ha7
$(PKG)_CONFIGURE_OPTIONS += --disable-ownet
$(PKG)_CONFIGURE_OPTIONS += --disable-owtap
$(PKG)_CONFIGURE_OPTIONS += --disable-owmon
$(PKG)_CONFIGURE_OPTIONS += --disable-swig
$(PKG)_CONFIGURE_OPTIONS += --disable-parport
$(PKG)_CONFIGURE_OPTIONS += --disable-owside
$(PKG)_CONFIGURE_OPTIONS += --disable-owcapi
$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-zero
$(PKG)_CONFIGURE_OPTIONS += --with-libusb-config="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/libusb-config"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_LIBS_BUILD_DIR) $($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(OWFS_DIR)

$($(PKG)_LIBS_TARGET_DIR): \
	$($(PKG)_DEST_DIR)/usr/lib/%: \
	$($(PKG)_DIR)/module/owlib/$(OWFS_LIB_BUILD_SUBDIR)/%
	$(INSTALL_LIBRARY_STRIP)

define OWFS_INSTALL_BINARY_STRIP
$($(PKG)_DEST_DIR)$(strip $(2))/$(notdir $(strip $(1))): $(strip $(1))
	$(value INSTALL_BINARY_STRIP)
endef
$(foreach binary,$($(PKG)_BINARIES_BUILD_DIR),$(eval $(call OWFS_INSTALL_BINARY_STRIP,$(binary),/usr/bin)))

$(pkg):

$(pkg)-precompiled: $($(PKG)_LIBS_TARGET_DIR) $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(OWFS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(OWFS_LIBS_TARGET_DIR)
	$(RM) $(OWFS_BINARIES_TARGET_DIR)

$(PKG_FINISH)
