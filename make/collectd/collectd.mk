$(call PKG_INIT_BIN, 4.10.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=c473cf8e9f22f5a9f7ef4c5be1b0c436
$(PKG)_SITE:=http://collectd.org/files

$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_TYPES_DB:=$($(PKG)_DIR)/src/types.db
$(PKG)_TARGET_TYPES_DB:=$($(PKG)_DEST_DIR)/usr/share/$(pkg)/types.db

# we need libltdl
$(PKG)_DEPENDS_ON := libtool
# ensure system libltdl is used and not the included one
$(PKG)_CONFIGURE_PRE_CMDS += $(RM) -r libltdl; sed -i -r -e '/SUBDIRS/ s/libltdl//g' ./Makefile.in;
$(PKG)_CONFIGURE_OPTIONS += --with-ltdl-include=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include
$(PKG)_CONFIGURE_OPTIONS += --with-ltdl-lib=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib

# remove -Werror flag
$(PKG)_CONFIGURE_PRE_CMDS += sed -i -r -e 's,-Werror,,g' ./configure ./src/Makefile.in ./src/libcollectdclient/Makefile.in ./src/owniptc/Makefile.in;

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --with-nan-emulation
$(PKG)_CONFIGURE_OPTIONS += --with-fp-layout=nothing #to be reevaluated for 7390

$(PKG)_PLUGINS_ENABLED :=
$(PKG)_PLUGINS_DISABLED :=

# TODO: revise disabled plugins & provide menuconfig options if it makes sense

# 'collect data'-plugins
$(PKG)_PLUGINS_DISABLED := \
	apache apcups apple_sensors ascent \
	battery bind \
	cpu cpufreq conntrack contextswitch curl curl_json curl_xml \
	dbi disk df dns \
	email entropy \
	filecount fscache \
	gmond \
	hddtemp \
	interface ipmi iptables ipvs irq \
	libvirt load \
	madwifi mbmon memcachec memcached memory modbus multimeter mysql \
	netapp netlink network nfs nginx ntpd nut \
	olsrd onewire openvpn oracle \
	pinba ping postgresql powerdns processes protocols \
	routeros \
	sensors serial snmp swap \
	table tail tape tcpconns teamspeak2 ted thermal tokyotyrant \
	uptime users \
	vmem vserver \
	wireless \
	xmms \
	zfs_arc

# output-plugins
$(PKG)_PLUGINS_DISABLED += csv network rrdcached rrdtool unixsock write_http

# binding-plugins
$(PKG)_PLUGINS_DISABLED += exec java perl python

# logging-plugins
$(PKG)_PLUGINS_DISABLED += logfile
$(PKG)_PLUGINS_ENABLED += syslog

# notification-plugins
$(PKG)_PLUGINS_DISABLED += notify_desktop notify_email

# 'filter chain'-plugins
$(PKG)_PLUGINS_DISABLED += \
	match_empty_counter match_hashed match_regex match_timediff match_value \
	target_notification target_replace target_scale target_set

# miscellaneous-plugins
$(PKG)_PLUGINS_DISABLED += uuid

# some plugins provide multiple features, e.g. they do both collect data & output it
# ensure disabled-plugins-list doesn't contain any plugin from the enabled-list
$(PKG)_PLUGINS_DISABLED := $(filter-out $($(PKG)_PLUGINS_ENABLED),$($(PKG)_PLUGINS_DISABLED))

$(PKG)_CONFIGURE_OPTIONS += $(foreach plugin,$($(PKG)_PLUGINS_DISABLED),--disable-$(plugin))
$(PKG)_CONFIGURE_OPTIONS += $(foreach plugin,$($(PKG)_PLUGINS_ENABLED),--enable-$(plugin))

$(PKG)_PLUGINS_DIR := $(FREETZ_LIBRARY_PATH)/$(pkg)
$(PKG)_PLUGINS_BUILD_DIR := $($(PKG)_PLUGINS_ENABLED:%=$($(PKG)_DIR)/src/.libs/%.so)
$(PKG)_PLUGINS_TARGET_DIR := $($(PKG)_PLUGINS_ENABLED:%=$($(PKG)_DEST_DIR)$($(PKG)_PLUGINS_DIR)/%.so)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(COLLECTD_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_PLUGINS_TARGET_DIR): $($(PKG)_DEST_DIR)$($(PKG)_PLUGINS_DIR)/%: $($(PKG)_DIR)/src/.libs/%
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_TYPES_DB): $($(PKG)_TYPES_DB)
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_TYPES_DB) $($(PKG)_PLUGINS_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(COLLECTD_DIR) clean

$(pkg)-uninstall:
	$(RM) -r $(COLLECTD_TARGET_BINARY) $(COLLECTD_TARGET_TYPES_DB) $(COLLECTD_DEST_DIR)$(COLLECTD_PLUGINS_DIR)

$(PKG_FINISH)
