$(call PKG_INIT_BIN, 3.9.8)
$(PKG)_SOURCE:=tcpdump-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.tcpdump.org/release
$(PKG)_BINARY:=$($(PKG)_DIR)/tcpdump
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/tcpdump

$(PKG)_DEPENDS_ON := libpcap

$(PKG)_CONFIGURE_PRE_CMDS += autoconf --force ;

$(PKG)_CONFIGURE_ENV += BUILD_CC="$(TARGET_CC)"
$(PKG)_CONFIGURE_ENV += HOSTCC="$(HOSTCC)"
$(PKG)_CONFIGURE_ENV += td_cv_gubbygetaddrinfo="no"

$(PKG)_CONFIGURE_OPTIONS += --disable-ipv6
$(PKG)_CONFIGURE_OPTIONS += --without-crypto


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(TCPDUMP_DIR) all \
		CCOPT="$(TARGET_CFLAGS)" \
		INCLS="-I." 

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

tcpdump: $($(PKG)_BINARY)

tcpdump-precompiled: $($(PKG)_TARGET_BINARY)

tcpdump-clean:
	-$(MAKE) -C $(TCPDUMP_DIR) clean

tcpdump-uninstall:
	rm -f $(TCPDUMP_TARGET_BINARY)

$(PKG_FINISH)
