$(call PKG_INIT_BIN, 4.68)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://nmap.org/dist
$(PKG)_BINARY:=$($(PKG)_DIR)/nmap
$(PKG)_SERVICES_LIST:=$($(PKG)_DIR)/nmap-services
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/nmap
$(PKG)_TARGET_SERVICES_LIST:=$($(PKG)_DEST_DIR)/usr/share/nmap/nmap-services
$(PKG)_SOURCE_MD5:=c363d32a00c697d15996fced22072b6c

$(PKG)_DEPENDS_ON := uclibcxx libpcap

$(PKG)_CONFIGURE_OPTIONS += --with-liblua=included
$(PKG)_CONFIGURE_OPTIONS += --with-pcap=linux
$(PKG)_CONFIGURE_OPTIONS += --with-pcre=included
$(PKG)_CONFIGURE_OPTIONS += --without-openssl
$(PKG)_CONFIGURE_OPTIONS += --with-pcap=linux
$(PKG)_CONFIGURE_OPTIONS += --with-nmapfe=no
$(PKG)_CONFIGURE_OPTIONS += --without-zenmap

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_SERVICES_LIST): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(NMAP_DIR)
	touch $(NMAP_SERVICES_LIST)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_SERVICES_LIST): $($(PKG)_SERVICES_LIST)
	mkdir -p $(dir $@)
	cp $^ $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_SERVICES_LIST)

$(pkg)-clean:
	-$(SUBMAKE) -C $(NMAP_DIR) clean
	$(RM) $(NMAP_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(NMAP_TARGET_BINARY)

$(PKG_FINISH)
