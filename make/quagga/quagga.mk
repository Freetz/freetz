$(call PKG_INIT_BIN, 0.99.15)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=8975414c76a295f4855a417af0b5ddce
$(PKG)_SITE:=http://www.quagga.net/download
$(PKG)_STARTLEVEL=80

# Libraries
$(PKG)_LIB_VERSION:=0.0.0
$(PKG)_LIB_SUFFIX:=so.$($(PKG)_LIB_VERSION)
$(PKG)_BINARY_BUILD_SUBDIR:=.libs
$(PKG)_LIBNAMES := libzebra
$(PKG)_LIBS_BUILD_DIR := $(QUAGGA_LIBNAMES:%=$($(PKG)_DIR)/lib/$($(PKG)_BINARY_BUILD_SUBDIR)/%.$(QUAGGA_LIB_SUFFIX))
$(PKG)_LIBS_TARGET_DIR := $(QUAGGA_LIBNAMES:%=$($(PKG)_DEST_DIR)/usr/lib/%.$(QUAGGA_LIB_SUFFIX))

# Executables
$(PKG)_BINARIES_ALL := zebra bgpd ripd ripngd ospfd ospf6d isisd vtysh
$(PKG)_BINARIES := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_BUILD_DIR := $(join $(QUAGGA_BINARIES:%=$($(PKG)_DIR)/%/.libs),$(QUAGGA_BINARIES:%=/%))
$(PKG)_BINARIES_TARGET_DIR := $(QUAGGA_BINARIES:%=$($(PKG)_DEST_DIR)/usr/sbin/%)

$(PKG)_NOT_INCLUDED := $(patsubst %,$($(PKG)_DEST_DIR)/usr/sbin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

$(PKG)_DEPENDS_ON := ncurses readline

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_QUAGGA_BGPD
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_QUAGGA_RIPD
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_QUAGGA_RIPNGD
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_QUAGGA_OSPFD
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_QUAGGA_OSPF6D
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_QUAGGA_ISISD

# touch configure.ac to prevent aclocal.m4 & configure from being regenerated
$(PKG)_CONFIGURE_PRE_CMDS += touch -t 200001010000.00 ./configure.ac;

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

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_LIBS_BUILD_DIR) $($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(QUAGGA_DIR) \
		LD="$(TARGET_LD)"

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/lib/%: $($(PKG)_DIR)/lib/.libs/%
	$(INSTALL_LIBRARY_STRIP)

$(foreach binary,$($(PKG)_BINARIES_BUILD_DIR),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),/usr/sbin)))

$(pkg):

$(pkg)-precompiled: $($(PKG)_LIBS_TARGET_DIR) $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(QUAGGA_DIR) clean
	$(RM) $(QUAGGA_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(QUAGGA_LIBS_TARGET_DIR) $(QUAGGA_BINARIES_TARGET_DIR)

$(PKG_FINISH)
