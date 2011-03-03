$(call PKG_INIT_BIN, 9.7.2-P3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://ftp.isc.org/isc/bind9/$($(PKG)_VERSION)
$(PKG)_SOURCE_MD5:=b4537cbae38b2daef36775bf49f33db9
$(PKG)_STARTLEVEL=40 # multid-wrapper may start it earlier!

$(PKG)_BINARY_BIND:=$($(PKG)_DIR)/bin/named/named
$(PKG)_TARGET_BINARY_BIND:=$($(PKG)_DEST_DIR)/usr/sbin/named
$(PKG)_BINARY_RNDC:=$($(PKG)_DIR)/bin/rndc/rndc
$(PKG)_TARGET_BINARY_RNDC:=$($(PKG)_DEST_DIR)/usr/sbin/rndc
$(PKG)_BINARY_NSUPDATE:=$($(PKG)_DIR)/bin/nsupdate/nsupdate
$(PKG)_TARGET_BINARY_NSUPDATE:=$($(PKG)_DEST_DIR)/usr/bin/nsupdate

$(PKG)_DEPENDS_ON := uclibcxx

$(PKG)_CONFIGURE_OPTIONS += BUILD_CC="$(TARGET_CC)"
$(PKG)_CONFIGURE_OPTIONS += --disable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-epoll=yes
$(PKG)_CONFIGURE_OPTIONS += --with-randomdev="/dev/urandom"
$(PKG)_CONFIGURE_OPTIONS += --with-libtool
$(PKG)_CONFIGURE_OPTIONS += --without-openssl
$(PKG)_CONFIGURE_OPTIONS += --without-libxml2
$(PKG)_CONFIGURE_OPTIONS += --disable-threads
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_BIND_IPV6),--enable-ipv6,--disable-ipv6)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY_BIND) $($(PKG)_BINARY_RNDC) $($(PKG)_BINARY_NSUPDATE): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(BIND_DIR)/lib/dns \
		BUILD_CC="$(HOSTCC)" \
		CC="$(HOSTCC)" \
		CFLAGS="-O2" \
		LIBS="" \
		gen
	$(SUBMAKE) -C $(BIND_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"
		

$($(PKG)_TARGET_BINARY_BIND): $($(PKG)_BINARY_BIND)
	$(INSTALL_BINARY_STRIP)

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


$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY_BIND) $($(PKG)_TARGET_BINARY_RNDC) $($(PKG)_TARGET_BINARY_NSUPDATE)

$(pkg)-clean:
	-$(SUBMAKE) -C $(BIND_DIR) clean
	$(RM) $(BIND_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(BIND_TARGET_BINARY) $(BIND_TARGET_BINARY_RNDC) $(BIND_TARGET_BINARY_NSUPDATE)


$(PKG_FINISH)
