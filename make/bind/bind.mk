$(call PKG_INIT_BIN, 9.8.0-P2)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://ftp.isc.org/isc/bind9/$($(PKG)_VERSION)
$(PKG)_SOURCE_MD5:=5f90dcf1730631feacdad3257c465c54

$(PKG)_STARTLEVEL=40 # multid-wrapper may start it earlier!

define $(PKG)_DEFS
$(PKG)_BINARIES_ALL_$(1)            := $(2)
$(PKG)_BINARIES_$(1)                := $$(call PKG_SELECTED_SUBOPTIONS,$$($(PKG)_BINARIES_ALL_$(1)))
$(PKG)_BINARIES_BUILD_DIR_$(1)      := $$(addprefix $$($(PKG)_DIR)/bin/, $$(join $$(addsuffix /,$$($(PKG)_BINARIES_$(1))),$$($(PKG)_BINARIES_$(1))))
$(PKG)_BINARIES_ALL_TARGET_DIR_$(1) := $$($(PKG)_BINARIES_ALL_$(1):%=$$($(PKG)_DEST_DIR)/usr/$(1)/%)
$(PKG)_BINARIES_TARGET_DIR_$(1)     := $$($(PKG)_BINARIES_$(1):%=$$($(PKG)_DEST_DIR)/usr/$(1)/%)
$(PKG)_NOT_INCLUDED                 += $$(filter-out $$($(PKG)_BINARIES_TARGET_DIR_$(1)),$$($(PKG)_BINARIES_ALL_TARGET_DIR_$(1)))
endef

$(eval $(call $(PKG)_DEFS,sbin,named rndc))
$(eval $(call $(PKG)_DEFS,bin,nsupdate dig))

$(PKG)_CONFIGURE_OPTIONS += BUILD_CC="$(HOSTCC)"
$(PKG)_CONFIGURE_OPTIONS += --disable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-epoll=no
$(PKG)_CONFIGURE_OPTIONS += --with-randomdev="/dev/urandom"
$(PKG)_CONFIGURE_OPTIONS += --with-libtool
$(PKG)_CONFIGURE_OPTIONS += --without-openssl
$(PKG)_CONFIGURE_OPTIONS += --without-libxml2
$(PKG)_CONFIGURE_OPTIONS += --disable-threads
$(PKG)_CONFIGURE_OPTIONS += --disable-backtrace
$(PKG)_CONFIGURE_OPTIONS += --disable-symtable
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)

$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR_sbin) $($(PKG)_BINARIES_BUILD_DIR_bin): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(BIND_DIR)/lib/dns gen
	$(SUBMAKE) -C $(BIND_DIR)

$(foreach binary,$($(PKG)_BINARIES_BUILD_DIR_sbin),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),/usr/sbin)))
$(foreach binary,$($(PKG)_BINARIES_BUILD_DIR_bin),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),/usr/bin)))

$(pkg): $($(PKG)_TARGET_DIR)/.exclude

$($(PKG)_TARGET_DIR)/.exclude: $(TOPDIR)/.config
	@echo -n "" > $@; \
	[ "$(FREETZ_PACKAGE_BIND_NAMED)" != "y" ] \
		&& echo "usr/lib/bind" >> $@ \
		&& echo "usr/lib/cgi-bin/bind.cgi" >> $@ \
		&& echo "etc/default.bind" >> $@ \
		&& echo "etc/init.d/rc.bind" >> $@; \
	touch $@

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR_sbin) $($(PKG)_BINARIES_TARGET_DIR_bin)

$(pkg)-clean:
	-$(SUBMAKE) -C $(BIND_DIR) clean
	$(RM) $(BIND_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(BIND_BINARIES_ALL_TARGET_DIR_sbin) $(BIND_BINARIES_ALL_TARGET_DIR_bin)

$(PKG_FINISH)
