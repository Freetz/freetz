$(call PKG_INIT_BIN, 4.1.1)
$(PKG)_SOURCE:=tcpdump-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=e6cd4bbd61ec7adbb61ba8352c4b4734f67b8caaa845d88cb826bc0b9f1e7f0a
$(PKG)_SITE:=http://www.tcpdump.org/release
### WEBSITE:=https://www.tcpdump.org
### MANPAGE:=https://www.tcpdump.org/manpages/tcpdump.1.html
### CHANGES:=https://git.tcpdump.org/tcpdump/blob/HEAD:/CHANGES
### CVSREPO:=https://github.com/the-tcpdump-group/tcpdump

$(PKG)_BINARY:=$($(PKG)_DIR)/tcpdump
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/tcpdump

$(PKG)_DEPENDS_ON += libpcap

ifeq ($(strip $(FREETZ_PACKAGE_TCPDUMP_MINI)),y)
$(PKG)_CFLAGS := -DTCPDUMP_MINI
$(PKG)_CONFIGURE_OPTIONS += --disable-smb
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TCPDUMP_MINI
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG)_CONFIGURE_ENV += td_cv_buggygetaddrinfo="no"
$(PKG)_CONFIGURE_ENV += ac_cv_path_PCAP_CONFIG=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/pcap-config

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)
$(PKG)_CONFIGURE_OPTIONS += --without-crypto


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(TCPDUMP_DIR) all \
		CCOPT="$(TARGET_CFLAGS) $(TCPDUMP_CFLAGS)" \
		INCLS="-I." \
		$(if $(FREETZ_PACKAGE_TCPDUMP_MINI),TCPDUMP_MINI=1,)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(TCPDUMP_DIR) clean

$(pkg)-uninstall:
	$(RM) $(TCPDUMP_TARGET_BINARY)

$(PKG_FINISH)
