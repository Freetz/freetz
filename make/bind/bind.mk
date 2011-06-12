$(call PKG_INIT_BIN, 9.8.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://ftp.isc.org/isc/bind9/$($(PKG)_VERSION)
$(PKG)_SOURCE_MD5:=e802ac97ca419c2ddfc043509bcb17bc
$(PKG)_STARTLEVEL=40 # multid-wrapper may start it earlier!

$(PKG)_BINARY_NAMED:=$($(PKG)_DIR)/bin/named/named
$(PKG)_TARGET_BINARY_NAMED:=$($(PKG)_DEST_DIR)/usr/sbin/named
$(PKG)_BINARY_RNDC:=$($(PKG)_DIR)/bin/rndc/rndc
$(PKG)_TARGET_BINARY_RNDC:=$($(PKG)_DEST_DIR)/usr/sbin/rndc
$(PKG)_BINARY_NSUPDATE:=$($(PKG)_DIR)/bin/nsupdate/nsupdate
$(PKG)_TARGET_BINARY_NSUPDATE:=$($(PKG)_DEST_DIR)/usr/bin/nsupdate
$(PKG)_BINARY_DIG:=$($(PKG)_DIR)/bin/dig/dig
$(PKG)_TARGET_BINARY_DIG:=$($(PKG)_DEST_DIR)/usr/bin/dig

$(PKG)_CONFIGURE_OPTIONS += BUILD_CC="$(HOSTCC)"
$(PKG)_CONFIGURE_OPTIONS += --disable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-epoll=yes
$(PKG)_CONFIGURE_OPTIONS += --with-randomdev="/dev/urandom"
$(PKG)_CONFIGURE_OPTIONS += --with-libtool
$(PKG)_CONFIGURE_OPTIONS += --without-openssl
$(PKG)_CONFIGURE_OPTIONS += --without-libxml2
$(PKG)_CONFIGURE_OPTIONS += --disable-threads
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)

$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY_NAMED) $($(PKG)_BINARY_RNDC) $($(PKG)_BINARY_NSUPDATE) $($(PKG)_BINARY_DIG): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(BIND_DIR)/lib/dns gen
	$(SUBMAKE) -C $(BIND_DIR)

$($(PKG)_TARGET_BINARY_NAMED): $($(PKG)_BINARY_NAMED)
ifeq ($(strip $(FREETZ_PACKAGE_BIND_NAMED)),y)
	$(INSTALL_BINARY_STRIP)
else
	$(RM) $@
endif

$($(PKG)_TARGET_BINARY_RNDC): $($(PKG)_BINARY_RNDC)
ifeq ($(strip $(FREETZ_PACKAGE_BIND_RNDC)),y)
	$(INSTALL_BINARY_STRIP)
else
	$(RM) $@
endif

$($(PKG)_TARGET_BINARY_NSUPDATE): $($(PKG)_BINARY_NSUPDATE)
ifeq ($(strip $(FREETZ_PACKAGE_BIND_NSUPDATE)),y)
	$(INSTALL_BINARY_STRIP)
else
	$(RM) $@
endif

$($(PKG)_TARGET_BINARY_DIG): $($(PKG)_BINARY_DIG)
ifeq ($(strip $(FREETZ_PACKAGE_BIND_DIG)),y)
	$(INSTALL_BINARY_STRIP)
else
	$(RM) $@
endif


$(pkg): $($(PKG)_TARGET_DIR)/.exclude

$($(PKG)_TARGET_DIR)/.exclude: $(TOPDIR)/.config
	@echo -n "" > $@; \
	[ "$(FREETZ_PACKAGE_BIND_NAMED)" != "y" ] \
		&& echo "usr/lib/bind" >> $@ \
		&& echo "usr/lib/cgi-bin/bind.cgi" >> $@ \
		&& echo "etc/default.bind" >> $@ \
		&& echo "etc/init.d/rc.bind" >> $@; \
	touch $@


$(pkg)-precompiled: $($(PKG)_TARGET_BINARY_NAMED) $($(PKG)_TARGET_BINARY_RNDC) $($(PKG)_TARGET_BINARY_NSUPDATE) $($(PKG)_TARGET_BINARY_DIG)

$(pkg)-clean:
	-$(SUBMAKE) -C $(BIND_DIR) clean
	$(RM) $(BIND_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(BIND_TARGET_BINARY_NAMED) $(BIND_TARGET_BINARY_RNDC) $(BIND_TARGET_BINARY_NSUPDATE) $(BIND_TARGET_BINARY_DIG)


$(PKG_FINISH)
