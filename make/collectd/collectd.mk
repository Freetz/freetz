$(call PKG_INIT_BIN, 4.0.7)
$(PKG)_VERSION:=4.0.7
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://collectd.org/files
$(PKG)_BINARY:=$($(PKG)_DIR)/src/collectd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/collectd
$(PKG)_SOURCE_MD5:=4ebb6308ff2c8ff0bf26770f38e81943 

$(PKG)_CONFIGURE_OPTIONS += --disable-apache
$(PKG)_CONFIGURE_OPTIONS += --disable-apcups
$(PKG)_CONFIGURE_OPTIONS += --disable-apple_sensors
$(PKG)_CONFIGURE_OPTIONS += --disable-battery
$(PKG)_CONFIGURE_OPTIONS += --disable-cpu
$(PKG)_CONFIGURE_OPTIONS += --disable-cpufreq
$(PKG)_CONFIGURE_OPTIONS += --disable-disk
$(PKG)_CONFIGURE_OPTIONS += --disable-csv
$(PKG)_CONFIGURE_OPTIONS += --disable-df
$(PKG)_CONFIGURE_OPTIONS += --disable-dns
$(PKG)_CONFIGURE_OPTIONS += --disable-email
$(PKG)_CONFIGURE_OPTIONS += --disable-entropy
$(PKG)_CONFIGURE_OPTIONS += --disable-exec
$(PKG)_CONFIGURE_OPTIONS += --disable-hddtemp
$(PKG)_CONFIGURE_OPTIONS += --disable-interface
$(PKG)_CONFIGURE_OPTIONS += --disable-iptables
$(PKG)_CONFIGURE_OPTIONS += --disable-irq
$(PKG)_CONFIGURE_OPTIONS += --disable-load
$(PKG)_CONFIGURE_OPTIONS += --disable-mbmon
$(PKG)_CONFIGURE_OPTIONS += --disable-memory
$(PKG)_CONFIGURE_OPTIONS += --disable-multimeter
$(PKG)_CONFIGURE_OPTIONS += --disable-mysql
$(PKG)_CONFIGURE_OPTIONS += --disable-network
$(PKG)_CONFIGURE_OPTIONS += --disable-nfs
$(PKG)_CONFIGURE_OPTIONS += --disable-ntpd
$(PKG)_CONFIGURE_OPTIONS += --disable-nut
$(PKG)_CONFIGURE_OPTIONS += --disable-perl
$(PKG)_CONFIGURE_OPTIONS += --disable-ping
$(PKG)_CONFIGURE_OPTIONS += --disable-processes
$(PKG)_CONFIGURE_OPTIONS += --disable-sensors
$(PKG)_CONFIGURE_OPTIONS += --disable-serial
$(PKG)_CONFIGURE_OPTIONS += --disable-logfile
$(PKG)_CONFIGURE_OPTIONS += --disable-swap
$(PKG)_CONFIGURE_OPTIONS += --disable-syslog
$(PKG)_CONFIGURE_OPTIONS += --disable-tape
$(PKG)_CONFIGURE_OPTIONS += --disable-unixsock
$(PKG)_CONFIGURE_OPTIONS += --disable-users
$(PKG)_CONFIGURE_OPTIONS += --disable-vserver
$(PKG)_CONFIGURE_OPTIONS += --disable-wireless
$(PKG)_CONFIGURE_OPTIONS += --with-nan-emulation


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(COLLECTD_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(COLLECTD_DIR) clean

$(pkg)-uninstall:
	$(RM) $(COLLECTD_TARGET_BINARY)

$(PKG_FINISH)
