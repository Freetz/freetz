$(call PKG_INIT_BIN, 1.13.18)
$(PKG)_LIB_VERSION:=3.29.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=8078f5c25e34ab907ce06905d969dc8ef0ccbec367e1e1707c7ecf8460f4254e
$(PKG)_SITE:=http://$(pkg).freedesktop.org/releases/$(pkg)

$(PKG)_STARTLEVEL=90 # before avahi

$(PKG)_BINARY:=$($(PKG)_DIR)/bus/.libs/dbus-daemon
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/dbus-daemon

$(PKG)_TOOLS_ALL           := monitor send uuidgen
$(PKG)_TOOLS               := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_TOOLS_ALL))
$(PKG)_TOOLS_BUILD_DIR     := $(addprefix $($(PKG)_DIR)/tools/.libs/dbus-, $($(PKG)_TOOLS_ALL))
$(PKG)_TOOLS_TARGET_DIR    := $($(PKG)_TOOLS:%=$($(PKG)_DEST_DIR)/usr/bin/dbus-%)
$(PKG)_EXCLUDED            += $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/dbus-%,$(filter-out $($(PKG)_TOOLS),$($(PKG)_TOOLS_ALL)))

$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/dbus/.libs/lib$(pkg)-1.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib$(pkg)-1.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_TARGET_LIBDIR)/lib$(pkg)-1.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIG_TEMPLATE_FILES := session.conf system.conf
$(PKG)_CONFIG_TEMPLATE_FILES_BUILD_DIR := $(addprefix $($(PKG)_DIR)/bus/,$($(PKG)_CONFIG_TEMPLATE_FILES))
$(PKG)_CONFIG_TEMPLATE_FILES_TARGET_DIR := $(addprefix $($(PKG)_DEST_DIR)/etc/config-template.dbus/,$($(PKG)_CONFIG_TEMPLATE_FILES))

$(PKG)_DEPENDS_ON += expat

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_ENV += ac_cv_func_accept4=no
$(PKG)_CONFIGURE_ENV += ac_cv_func_poll=no

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-abstract-sockets
$(PKG)_CONFIGURE_OPTIONS += --enable-asserts
$(PKG)_CONFIGURE_OPTIONS += --disable-ansi
$(PKG)_CONFIGURE_OPTIONS += --enable-checks
$(PKG)_CONFIGURE_OPTIONS += --disable-compiler_coverage
$(PKG)_CONFIGURE_OPTIONS += --disable-console-owner-file
$(PKG)_CONFIGURE_OPTIONS += --disable-dnotify
$(PKG)_CONFIGURE_OPTIONS += --disable-doxygen-docs
$(PKG)_CONFIGURE_OPTIONS += --disable-epoll
$(PKG)_CONFIGURE_OPTIONS += --enable-inotify
$(PKG)_CONFIGURE_OPTIONS += --disable-kqueue
$(PKG)_CONFIGURE_OPTIONS += --disable-option-checking
$(PKG)_CONFIGURE_OPTIONS += --disable-selinux
$(PKG)_CONFIGURE_OPTIONS += --disable-silent-rules
$(PKG)_CONFIGURE_OPTIONS += --disable-tests
$(PKG)_CONFIGURE_OPTIONS += --disable-verbose-mode
$(PKG)_CONFIGURE_OPTIONS += --disable-xml-docs
$(PKG)_CONFIGURE_OPTIONS += --with-init-scripts=none
$(PKG)_CONFIGURE_OPTIONS += --with-x=no
$(PKG)_CONFIGURE_OPTIONS += --with-xml=expat
$(PKG)_CONFIGURE_OPTIONS += --with-dbus-user=nobody

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_LIB_BINARY) $($(PKG)_TOOLS_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(DBUS_DIR)

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	$(SUBMAKE) -C $(DBUS_DIR)/dbus \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(SUBMAKE) -C $(DBUS_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install-pkgconfigDATA
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libdbus-1.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/dbus-1.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$($(PKG)_TOOLS_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/tools/.libs/%
	$(INSTALL_BINARY_STRIP)

$($(PKG)_CONFIG_TEMPLATE_FILES_BUILD_DIR): $($(PKG)_DIR)/.configured
	@touch -c $@

$($(PKG)_CONFIG_TEMPLATE_FILES_TARGET_DIR): $($(PKG)_DEST_DIR)/etc/config-template.dbus/%: $($(PKG)_DIR)/bus/%
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_LIB_TARGET_BINARY) $($(PKG)_TOOLS_TARGET_DIR) $($(PKG)_CONFIG_TEMPLATE_FILES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(DBUS_DIR) clean
	 $(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libdbus-1* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/dbus-1.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/etc/dbus-1* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/dbus-1.0 \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/dbus-1.0 \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/dbus-1*

$(pkg)-uninstall:
	$(RM) \
		$(DBUS_TARGET_BINARY) \
		$(DBUS_TARGET_LIBDIR)/libdbus-1*.so* \
		$(DBUS_TOOLS_ALL:%=$(DBUS_DEST_DIR)/usr/bin/dbus-%) \
		$(DBUS_CONFIG_TEMPLATE_FILES_TARGET_DIR)

$(PKG_FINISH)
