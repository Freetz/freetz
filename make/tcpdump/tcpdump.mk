$(call PKG_INIT_BIN, 4.1.1)
$(PKG)_SOURCE:=tcpdump-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.tcpdump.org/release
$(PKG)_BINARY:=$($(PKG)_DIR)/tcpdump
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/tcpdump
$(PKG)_SOURCE_MD5:=d0dd58bbd6cd36795e05c6f1f74420b0

$(PKG)_DEPENDS_ON := libpcap

$(PKG)_CONFIGURE_ENV += td_cv_buggygetaddrinfo="no"
$(PKG)_CONFIGURE_ENV += ac_cv_path_PCAP_CONFIG=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/pcap-config

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)
$(PKG)_CONFIGURE_OPTIONS += --without-crypto

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(TCPDUMP_DIR) all \
		CCOPT="$(TARGET_CFLAGS)" \
		INCLS="-I."

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(TCPDUMP_DIR) clean

$(pkg)-uninstall:
	$(RM) $(TCPDUMP_TARGET_BINARY)

$(PKG_FINISH)
