$(call PKG_INIT_BIN, 3.14.6)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=a57233cd0e2db1dcf1d34d8b90c6a9d3e027e522695aada6c3c411a839868b8e
$(PKG)_SITE:=@SF/hplip

$(PKG)_LIB_IP_VERSION=0.0.1
$(PKG)_LIB_IP_BINARY:=$($(PKG)_DIR)/.libs/libhpip.so.$($(PKG)_LIB_IP_VERSION)
$(PKG)_LIB_IP_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libhpip.so.$($(PKG)_LIB_IP_VERSION)
$(PKG)_LIB_IP_TARGET_BINARY:=$($(PKG)_DEST_LIBDIR)/libhpip.so.$($(PKG)_LIB_IP_VERSION)
$(PKG)_LIB_MUD_VERSION=0.0.6
$(PKG)_LIB_MUD_BINARY:=$($(PKG)_DIR)/.libs/libhpmud.so.$($(PKG)_LIB_MUD_VERSION)
$(PKG)_LIB_MUD_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libhpmud.so.$($(PKG)_LIB_MUD_VERSION)
$(PKG)_LIB_MUD_TARGET_BINARY:=$($(PKG)_DEST_LIBDIR)/libhpmud.so.$($(PKG)_LIB_MUD_VERSION)
$(PKG)_LIB_HPAIO_VERSION=1.0.0
$(PKG)_LIB_HPAIO_BINARY:=$($(PKG)_DIR)/.libs/libsane-hpaio.so.$($(PKG)_LIB_HPAIO_VERSION)
$(PKG)_LIB_HPAIO_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/sane/libsane-hpaio.so.$($(PKG)_LIB_HPAIO_VERSION)
$(PKG)_LIB_HPAIO_TARGET_BINARY:=$($(PKG)_DEST_LIBDIR)/sane/libsane-hpaio.so.$($(PKG)_LIB_HPAIO_VERSION)
$(PKG)_CATEGORY:=Unstable

$(PKG)_DEPENDS_ON += libusb1 sane-backends

$(PKG)_REBUILD_SUBOPTS += $(LIBUSB_REBUILD_SUBOPTS)

$(PKG)_CONFIGURE_PRE_CMDS += touch NEWS README AUTHORS ChangeLog;
$(PKG)_CONFIGURE_PRE_CMDS += $(AUTORECONF)
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --enable-lite-build
$(PKG)_CONFIGURE_OPTIONS += --disable-doc-build
$(PKG)_CONFIGURE_OPTIONS += --disable-network-build
$(PKG)_CONFIGURE_OPTIONS += --disable-pp-build
$(PKG)_CONFIGURE_OPTIONS += --disable-gui-build
$(PKG)_CONFIGURE_OPTIONS += --disable-fax-build
$(PKG)_CONFIGURE_OPTIONS += --disable-dbus-build
$(PKG)_CONFIGURE_OPTIONS += --disable-cups-drv-install
$(PKG)_CONFIGURE_OPTIONS += --disable-foomatic-drv-install
$(PKG)_CONFIGURE_OPTIONS += --disable-foomatic-rip-hplip-install
$(PKG)_CONFIGURE_OPTIONS += --disable-hpcups-install

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_LIB_IP_BINARY) \
	$($(PKG)_LIB_MUD_BINARY) \
	$($(PKG)_LIB_HPAIO_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(HPLIP_DIR)

$($(PKG)_LIB_IP_STAGING_BINARY) \
	$($(PKG)_LIB_MUD_STAGING_BINARY) \
	$($(PKG)_LIB_HPAIO_STAGING_BINARY): $($(PKG)_LIB_IP_BINARY) \
						$($(PKG)_LIB_MUD_BINARY) \
						$($(PKG)_LIB_HPAIO_BINARY)
	$(SUBMAKE) -C $(HPLIP_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libhpip.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libhpmud.la
	cp $(HPLIP_DIR)/io/hpmud/hpmud.h $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include

$($(PKG)_LIB_IP_TARGET_BINARY): $($(PKG)_LIB_IP_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$($(PKG)_LIB_MUD_TARGET_BINARY): $($(PKG)_LIB_MUD_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$($(PKG)_LIB_HPAIO_TARGET_BINARY): $($(PKG)_LIB_HPAIO_STAGING_BINARY)
	mkdir -p $(HPLIP_DEST_LIBDIR)/sane
	mkdir -p $(HPLIP_DEST_DIR)/etc
	mkdir -p $(HPLIP_DEST_DIR)/usr/share/hplip/data/models
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/sane/libsane-hpaio.so* $(HPLIP_DEST_LIBDIR)/sane
	cp -R $(TARGET_TOOLCHAIN_STAGING_DIR)/etc/default.hplip $(HPLIP_DEST_DIR)/etc
	$(TARGET_STRIP) $@

$(PKG)_TARGET_CONF:
	$(call MESSAGE,HPLIP: Strip down models.dat to $(subst ",,$(FREETZ_PACKAGE_HPLIP_PRINTER_TYPE)))
	@awk '/^\[.*\]/{p=0} $$0=="[$(subst ",,$(FREETZ_PACKAGE_HPLIP_PRINTER_TYPE))]"{p=1} p && !/^$$/' \
		< $(HPLIP_DIR)/data/models/models.dat \
		> $(HPLIP_DEST_DIR)/usr/share/hplip/data/models/models.dat

.PHONY: $(PKG)_TARGET_CONF

$(pkg):

$(pkg)-precompiled: $($(PKG)_LIB_IP_TARGET_BINARY) \
			$($(PKG)_LIB_MUD_TARGET_BINARY) \
			$($(PKG)_LIB_HPAIO_TARGET_BINARY) \
			$(PKG)_TARGET_CONF

$(pkg)-clean:
	-$(SUBMAKE) -C $(HPLIP_DIR) clean

$(pkg)-config-update:
	$(HPLIP_MAKE_DIR)/hplip-config-update.py $(HPLIP_VERSION) \
		$(HPLIP_DIR)/data/models/models.dat > $(HPLIP_MAKE_DIR)/Config.in

$(pkg)-uninstall:
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libhp* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/sane/libsane-hpaio* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/hpmud.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/hplip \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/var/log/hp \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/etc/default.hplip

$(PKG_FINISH)
