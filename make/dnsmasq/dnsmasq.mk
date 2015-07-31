$(call PKG_INIT_BIN, 2.75)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_MD5:=887236f1ddde6eb57cdb9d01916c9f72
$(PKG)_SITE:=http://thekelleys.org.uk/dnsmasq
#$(PKG)_SITE:=git://thekelleys.org.uk/dnsmasq.git

$(PKG)_STARTLEVEL=40 # multid-wrapper may start it earlier!

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_AVM_VERSION_05_5X_MAX),multid)

$(PKG)_BINARY:=$($(PKG)_DIR)/src/dnsmasq
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/dnsmasq

$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT
$(PKG)_REBUILD_SUBOPTS += FREETZ_AVM_HAS_MULTID_LEASES_FORMAT_V2
$(PKG)_REBUILD_SUBOPTS += FREETZ_AVM_VERSION_05_5X_MAX

$(PKG)_COPTS := -DCONFFILE=\\\"/mod/etc/dnsmasq.conf\\\"
$(PKG)_COPTS += -DRUNFILE=\\\"/var/run/dnsmasq/dnsmasq.pid\\\"
$(PKG)_COPTS += -DLEASEFILE=\\\"/var/tmp/dnsmasq.leases\\\"
$(PKG)_COPTS += -DNO_INOTIFY
ifneq ($(FREETZ_TARGET_IPV6_SUPPORT),y)
$(PKG)_COPTS += -DNO_IPV6
endif
ifeq ($(FREETZ_AVM_HAS_MULTID_LEASES_FORMAT_V2),y)
$(PKG)_COPTS += -DMULTID_LEASES_FORMAT_V2
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(DNSMASQ_DIR) \
		CC="$(TARGET_CC)" \
		COPTS="$(DNSMASQ_COPTS)" \
		CFLAGS="$(TARGET_CFLAGS) -ffunction-sections -fdata-sections" \
		LDFLAGS="-Wl,--gc-sections" \
		version=-DVERSION=\'\\\"$(DNSMASQ_VERSION)\\\"\'

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(DNSMASQ_DIR) clean

$(pkg)-uninstall:
	$(RM) $(DNSMASQ_TARGET_BINARY)

$(PKG_FINISH)
