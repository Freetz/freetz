$(call PKG_INIT_BIN, 0.6.30)
$(PKG)_SOURCE:=avahi-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://avahi.org/download/
$(PKG)_SOURCE_MD5:=e4db89a2a403ff4c47d66ac66fad1f43

$(PKG)_BINARIES := avahi-daemon 
$(PKG)_BINARIES += $(if $(FREETZ_PACKAGE_AVAHI_WITH_DNSCONFD),avahi-dnsconfd,) 
$(PKG)_BINARIES_BUILD_DIR := $(join $($(PKG)_BINARIES:%=$($(PKG)_DIR)/%/.libs/),$($(PKG)_BINARIES:%=%))
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/sbin/%)

$(PKG)_LIB_VERSIONS := 3.5.3 7.0.2 3.2.9
$(PKG)_LIB_SUFFIX := so.$($(PKG)_LIB_VERSION)
$(PKG)_LIBNAMES_SHORT := avahi-common avahi-core avahi-client
$(PKG)_LIBNAMES_LONG := $(join $($(PKG)_LIBNAMES_SHORT:%=lib%),$($(PKG)_LIB_VERSIONS:%=.so.%))
$(PKG)_LIBS_BUILD_DIR := $(join $($(PKG)_LIBNAMES_SHORT:%=$($(PKG)_DIR)/%/.libs/),$($(PKG)_LIBNAMES_LONG:%=%))
$(PKG)_LIBS_STAGING_DIR := $($(PKG)_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)
$(PKG)_LIBS_TARGET_DIR := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_DEST_LIBDIR)/%)
#$(PKG)_LIBS_TARGET_DIR := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_TARGET_LIBDIR)/%)

$(PKG)_DEPENDS_ON := dbus expat libdaemon

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-glib
$(PKG)_CONFIGURE_OPTIONS += --disable-gobject
$(PKG)_CONFIGURE_OPTIONS += --disable-qt3
$(PKG)_CONFIGURE_OPTIONS += --disable-qt4
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk3
$(PKG)_CONFIGURE_OPTIONS += --enable-dbus
$(PKG)_CONFIGURE_OPTIONS += --with-xml=expat
$(PKG)_CONFIGURE_OPTIONS += --disable-dbm
$(PKG)_CONFIGURE_OPTIONS += --disable-gdbm
$(PKG)_CONFIGURE_OPTIONS += --enable-libdaemon
$(PKG)_CONFIGURE_OPTIONS += --disable-python
$(PKG)_CONFIGURE_OPTIONS += --disable-pygtk
$(PKG)_CONFIGURE_OPTIONS += --disable-python-dbus
$(PKG)_CONFIGURE_OPTIONS += --disable-mono
$(PKG)_CONFIGURE_OPTIONS += --disable-monodoc
$(PKG)_CONFIGURE_OPTIONS += --disable-doxygen-doc
$(PKG)_CONFIGURE_OPTIONS += --disable-doxygen-dot
$(PKG)_CONFIGURE_OPTIONS += --disable-doxygen-man
$(PKG)_CONFIGURE_OPTIONS += --disable-doxygen-rtf
$(PKG)_CONFIGURE_OPTIONS += --disable-doxygen-xml
$(PKG)_CONFIGURE_OPTIONS += --disable-doxygen-chm
$(PKG)_CONFIGURE_OPTIONS += --disable-doxygen-chi
$(PKG)_CONFIGURE_OPTIONS += --disable-doxygen-html
$(PKG)_CONFIGURE_OPTIONS += --disable-doxygen-ps
$(PKG)_CONFIGURE_OPTIONS += --disable-doxygen-pdf
$(PKG)_CONFIGURE_OPTIONS += --disable-xmltoman
$(PKG)_CONFIGURE_OPTIONS += --with-distro=none
$(PKG)_CONFIGURE_OPTIONS += --with-avahi-user=nobody
$(PKG)_CONFIGURE_OPTIONS += --with-avahi-group=nobody
$(PKG)_CONFIGURE_OPTIONS += --with-autoipd-user=nobody
$(PKG)_CONFIGURE_OPTIONS += --with-autoipd-group=nobody

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_LIBS_BUILD_DIR) $($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(AVAHI_DIR)

$($(PKG)_LIBS_STAGING_DIR): $($(PKG)_LIBS_BUILD_DIR)
		$(SUBMAKE) -C $(AVAHI_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
		$(PKG_FIX_LIBTOOL_LA) \
			$(AVAHI_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib%.la) \
			$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/avahi-client.pc \
			$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/avahi-core.pc

$(foreach binary,$($(PKG)_BINARIES_BUILD_DIR),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),/usr/sbin)))
$(foreach library,$($(PKG)_LIBS_STAGING_DIR),$(eval $(call INSTALL_LIBRARY_STRIP_RULE,$(library),$(FREETZ_LIBRARY_PATH))))

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR) $($(PKG)_LIBS_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(AVAHI_DIR) clean
	$(RM) $(AVAHI_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(AVAHI_TARGET_BINARY)

$(PKG_FINISH)
