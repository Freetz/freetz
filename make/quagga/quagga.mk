$(call PKG_INIT_BIN, 0.99.6)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.quagga.net/download
$(PKG)_BINARY:=$($(PKG)_DIR)/zebra/.libs/zebra
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/zebra
$(PKG)_TARGET_LIBDIR:=$($(PKG)_DEST_DIR)/usr/lib
$(PKG)_STARTLEVEL=80

$(PKG)_DEPENDS_ON := ncurses readline

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_QUAGGA_BGPD
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_QUAGGA_RIPD
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_QUAGGA_RIPNGD
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_QUAGGA_OSPFD
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_QUAGGA_OSPF6D
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_QUAGGA_ISISD

$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/etc/quagga
$(PKG)_CONFIGURE_OPTIONS += --localstatedir=/var/run/quagga
$(PKG)_CONFIGURE_OPTIONS += --enable-user=root
$(PKG)_CONFIGURE_OPTIONS += --enable-group=root
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-multipath=8
$(PKG)_CONFIGURE_OPTIONS += --enable-vtysh
$(PKG)_CONFIGURE_OPTIONS += --disable-capabilities
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_QUAGGA_BGPD),--enable-bgpd,--disable-bgpd)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_QUAGGA_RIPD),--enable-ripd,--disable-ripd)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_QUAGGA_RIPNGD),--enable-ripngd,--disable-ripngd)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_QUAGGA_OSPFD),--enable-ospfd,--disable-ospfd)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_QUAGGA_OSPF6D),--enable-ospf6d,--disable-ospf6d)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_QUAGGA_ISISD),--enable-isisd,--disable-isisd)

$(PKG)_DAEMONS:=zebra \
		$(if $(FREETZ_PACKAGE_QUAGGA_BGPD),bgpd,) \
		$(if $(FREETZ_PACKAGE_QUAGGA_RIPD),ripd,) \
		$(if $(FREETZ_PACKAGE_QUAGGA_RIPNGD),ripngd,) \
		$(if $(FREETZ_PACKAGE_QUAGGA_OSPFD),ospfd,) \
	        $(if $(FREETZ_PACKAGE_QUAGGA_OSPF6D),ospf6d,) \
		$(if $(FREETZ_PACKAGE_QUAGGA_ISISD),isisd,)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		LD="$(TARGET_LD)" \
		$(MAKE) -C $(QUAGGA_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	# copy, strip and chmod base libs
	cp -d $(QUAGGA_DIR)/lib/.libs/lib*.so* $(QUAGGA_TARGET_LIBDIR)
	$(TARGET_STRIP) $(QUAGGA_TARGET_LIBDIR)/lib*.so*
	chmod -x $(QUAGGA_TARGET_LIBDIR)/lib*.so*
	# vtysh
	cp $(QUAGGA_DIR)/vtysh/.libs/vtysh $(QUAGGA_DEST_DIR)/usr/bin
	$(TARGET_STRIP) $(QUAGGA_DEST_DIR)/usr/bin/vtysh
	# install routing routing daemons and libs
	mkdir -p $(QUAGGA_DEST_DIR)/usr/sbin $(QUAGGA_TARGET_LIBDIR)
	for d in $(QUAGGA_DAEMONS); do \
		if [ -f $(QUAGGA_DIR)/$$d/.libs/$$d ]; then \
			cp $(QUAGGA_DIR)/$$d/.libs/$$d $(QUAGGA_DEST_DIR)/usr/sbin; \
			$(TARGET_STRIP) $(QUAGGA_DEST_DIR)/usr/sbin/$$d; \
		fi; \
		(shopt -s nullglob; for f in $(QUAGGA_DIR)/$$d/.libs/lib*.so*; do \
			cp -d $$f $(QUAGGA_TARGET_LIBDIR); \
		done;) \
	done
	# install supervisor daemon
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(QUAGGA_DIR) clean
	$(RM) $(QUAGGA_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(QUAGGA_TARGET_LIBDIR)/lib*.so*	
	$(RM) $(QUAGGA_DEST_DIR)/usr/sbin/*
	$(RM) $(QUAGGA_DEST_DIR)/usr/bin/vtysh

$(PKG_FINISH)
