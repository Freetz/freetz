$(call PKG_INIT_BIN, 2.81)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_SHA256:=749ca903537c5197c26444ac24b0dce242cf42595fdfe6b9a5b9e4c7ad32f8fb
$(PKG)_SITE:=http://thekelleys.org.uk/dnsmasq
#$(PKG)_SITE:=git://thekelleys.org.uk/dnsmasq.git

$(PKG)_STARTLEVEL=40 # multid-wrapper may start it earlier!

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_AVM_VERSION_05_5X_MAX),multid)

$(PKG)_BINARY:=$($(PKG)_DIR)/src/dnsmasq
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/dnsmasq

$(PKG)_TRUST_ANCHORS:=$($(PKG)_DIR)/trust-anchors.conf
$(PKG)_TARGET_TRUST_ANCHORS:=$($(PKG)_DEST_DIR)/etc/default.dnsmasq/trust-anchors.conf

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DNSMASQ_WITH_DNSSEC
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
ifeq ($(FREETZ_PACKAGE_DNSMASQ_WITH_DNSSEC),y)
$(PKG)_DEPENDS_ON += nettle
$(PKG)_COPTS += -DHAVE_DNSSEC -DHAVE_DNSSEC_STATIC
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
		version=-DVERSION=\'\\\"$(DNSMASQ_VERSION)\\\"\' \
		PKG_CONFIG_PATH="$(TARGET_MAKE_PATH)/../lib/pkgconfig"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TRUST_ANCHORS): $($(PKG)_DIR)/.unpacked
	@touch -c $@

$($(PKG)_TARGET_TRUST_ANCHORS): $($(PKG)_TRUST_ANCHORS)
	@mkdir -p $(dir $@); cat $< | grep "^trust-anchor" > $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $(if $(FREETZ_PACKAGE_DNSMASQ_WITH_DNSSEC),$($(PKG)_TARGET_TRUST_ANCHORS))

$(pkg)-clean:
	-$(SUBMAKE) -C $(DNSMASQ_DIR) clean

$(pkg)-uninstall:
	$(RM) $(DNSMASQ_TARGET_BINARY) $(DNSMASQ_TARGET_TRUST_ANCHORS)

$(PKG_FINISH)
