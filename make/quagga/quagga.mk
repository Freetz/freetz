$(call PKG_INIT_BIN, 0.99.17)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=1d77df121a334e9504b45e489ee7ce35bf478e27d33cd2793a23280b59d9efd4
$(PKG)_SITE:=http://www.quagga.net/download
$(PKG)_STARTLEVEL=82

# Libraries
$(PKG)_LIBZEBRA      := libzebra.so.0.0.0
$(PKG)_LIBOSPF_SO    := libospf.so
$(PKG)_LIBOSPF_MAJOR := $($(PKG)_LIBOSPF_SO).0
$(PKG)_LIBOSPF       := $($(PKG)_LIBOSPF_MAJOR).0.0
$(PKG)_LIBS_ALL      := $($(PKG)_LIBZEBRA) $($(PKG)_LIBOSPF)

$(PKG)_LIBS := $($(PKG)_LIBZEBRA)
$(PKG)_LIBS_SUBDIRS := lib/.libs/
ifeq ($(strip $(FREETZ_PACKAGE_QUAGGA_OSPFD)),y)
$(PKG)_LIBS += $($(PKG)_LIBOSPF)
$(PKG)_LIBS_SUBDIRS += ospfd/.libs/
endif
$(PKG)_LIBS_BUILD_DIR := $(addprefix $($(PKG)_DIR)/,$(join $($(PKG)_LIBS_SUBDIRS),$($(PKG)_LIBS)))
$(PKG)_LIBS_TARGET_DIR := $(addprefix $($(PKG)_DEST_LIBDIR)/,$($(PKG)_LIBS))

# Executables
$(PKG)_BINARIES_ALL := zebra bgpd ripd ripngd ospfd ospf6d isisd vtysh
$(PKG)_BINARIES := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_BUILD_DIR := $(join $($(PKG)_BINARIES:%=$($(PKG)_DIR)/%/.libs/),$($(PKG)_BINARIES))
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/sbin/%)

$(PKG)_EXCLUDED += $(patsubst %,$($(PKG)_DEST_DIR)/usr/sbin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))
ifneq ($(strip $(FREETZ_PACKAGE_QUAGGA_OSPFD)),y)
$(PKG)_EXCLUDED += $(addprefix $($(PKG)_DEST_LIBDIR)/,$($(PKG)_LIBOSPF_SO) $($(PKG)_LIBOSPF_MAJOR) $($(PKG)_LIBOSPF))
endif

$(PKG)_DEPENDS_ON += ncurses readline

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
$(PKG)_CONFIGURE_OPTIONS += --disable-pie
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
		MAKEINFO=true

$(foreach binary,$($(PKG)_BINARIES_BUILD_DIR),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),/usr/sbin)))

$(foreach library,$($(PKG)_LIBS_BUILD_DIR),$(eval $(call INSTALL_LIBRARY_STRIP_RULE,$(library),$(FREETZ_LIBRARY_DIR))))

$(pkg):

$(pkg)-precompiled: $($(PKG)_LIBS_TARGET_DIR) $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(QUAGGA_DIR) clean
	$(RM) $(QUAGGA_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(QUAGGA_BINARIES_TARGET_DIR) $(QUAGGA_DEST_LIBDIR)/libzebra* $(QUAGGA_DEST_LIBDIR)/libospf*

$(PKG_FINISH)
