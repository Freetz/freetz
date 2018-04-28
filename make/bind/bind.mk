$(call PKG_INIT_BIN, 9.11.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA256:=0d9dde14b2ec7f9cdc3b69f19540c7a2e4eee7b6c727965dfae48810965876f5
$(PKG)_SITE:=http://ftp.isc.org/isc/bind9/$($(PKG)_VERSION)

$(PKG)_STARTLEVEL=40 # multid-wrapper may start it earlier!

define $(PKG)_DEFS
$(PKG)_BINARIES_ALL_$(1)            := $(2)
$(PKG)_BINARIES_$(1)                := $$(call PKG_SELECTED_SUBOPTIONS,$$($(PKG)_BINARIES_ALL_$(1)))
$(PKG)_BINARIES_BUILD_DIR_$(1)      := $$(addprefix $$($(PKG)_DIR)/bin/, $$(join $$(addsuffix /,$$($(PKG)_BINARIES_$(1))),$$($(PKG)_BINARIES_$(1))))
$(PKG)_BINARIES_ALL_TARGET_DIR_$(1) := $$($(PKG)_BINARIES_ALL_$(1):%=$$($(PKG)_DEST_DIR)/usr/$(1)/%)
$(PKG)_BINARIES_TARGET_DIR_$(1)     := $$($(PKG)_BINARIES_$(1):%=$$($(PKG)_DEST_DIR)/usr/$(1)/%)
$(PKG)_EXCLUDED                     += $$(filter-out $$($(PKG)_BINARIES_TARGET_DIR_$(1)),$$($(PKG)_BINARIES_ALL_TARGET_DIR_$(1)))
endef

$(eval $(call $(PKG)_DEFS,sbin,named rndc))
$(eval $(call $(PKG)_DEFS,bin,nsupdate dig))

$(PKG)_EXCLUDED+=$(if $(FREETZ_PACKAGE_BIND_NAMED),,usr/lib/bind usr/lib/cgi-bin/bind.cgi etc/default.bind etc/init.d/rc.bind)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_MAKE_AC_VARIABLES_PACKAGE_SPECIFIC,c_inline)

$(PKG)_CONFIGURE_OPTIONS += BUILD_CC="$(HOSTCC)"
$(PKG)_CONFIGURE_OPTIONS += --disable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-epoll=no
$(PKG)_CONFIGURE_OPTIONS += --with-randomdev="/dev/random"
$(PKG)_CONFIGURE_OPTIONS += --with-libtool
$(PKG)_CONFIGURE_OPTIONS += --without-openssl
$(PKG)_CONFIGURE_OPTIONS += --without-gssapi
$(PKG)_CONFIGURE_OPTIONS += --disable-isc-spnego
$(PKG)_CONFIGURE_OPTIONS += --without-pkcs11
$(PKG)_CONFIGURE_OPTIONS += --without-idnlib
$(PKG)_CONFIGURE_OPTIONS += --without-purify
$(PKG)_CONFIGURE_OPTIONS += --without-libjson
$(PKG)_CONFIGURE_OPTIONS += --without-libxml2
$(PKG)_CONFIGURE_OPTIONS += --without-zlib
$(PKG)_CONFIGURE_OPTIONS += --disable-threads
$(PKG)_CONFIGURE_OPTIONS += --disable-backtrace
$(PKG)_CONFIGURE_OPTIONS += --disable-symtable
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)

$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG)_MAKE_FLAGS += EXTRA_CFLAGS="-ffunction-sections -fdata-sections" EXTRA_BINARY_LDFLAGS="-Wl,--gc-sections"

$(PKG)_EXPORT_LIB_DIR := $(FREETZ_BASE_DIR)/$(BIND_DIR)/_exportlib
#$(PKG)_CONFIGURE_OPTIONS += --enable-exportlib
#$(PKG)_CONFIGURE_OPTIONS += --with-export-includedir="$($(PKG)_EXPORT_LIB_DIR)/include"
#$(PKG)_CONFIGURE_OPTIONS += --with-export-libdir="$($(PKG)_EXPORT_LIB_DIR)/lib"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_DIR)/.compiled: $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(BIND_DIR) $(BIND_MAKE_FLAGS)
	@touch $@

$($(PKG)_EXPORT_LIB_DIR)/.installed: $($(PKG)_DIR)/.compiled
	$(SUBMAKE1) -C $(BIND_DIR)/lib $(BIND_MAKE_FLAGS) \
		DESTDIR=$(BIND_EXPORT_LIB_DIR) \
		install
	@touch $@

$($(PKG)_BINARIES_BUILD_DIR_sbin) $($(PKG)_BINARIES_BUILD_DIR_bin): $($(PKG)_DIR)/.compiled
	@touch -c $@

$(foreach binary,$($(PKG)_BINARIES_BUILD_DIR_sbin),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),/usr/sbin)))
$(foreach binary,$($(PKG)_BINARIES_BUILD_DIR_bin),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),/usr/bin)))

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR_sbin) $($(PKG)_BINARIES_TARGET_DIR_bin) $($(PKG)_EXPORT_LIB_DIR)/.installed

$(pkg)-clean:
	-$(SUBMAKE) -C $(BIND_DIR) clean
	$(RM) -r $(BIND_DIR)/.configured $(BIND_DIR)/.compiled $(BIND_EXPORT_LIB_DIR)/.installed $(BIND_EXPORT_LIB_DIR)

$(pkg)-uninstall:
	$(RM) $(BIND_BINARIES_ALL_TARGET_DIR_sbin) $(BIND_BINARIES_ALL_TARGET_DIR_bin)

$(PKG_FINISH)
