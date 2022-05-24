$(call PKG_INIT_BIN, 4.10.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=ffd1959273301b302c144057baf68128e62c42bcff156ba941336e7389439b65
$(PKG)_SITE:=http://collectd.org/files

$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)
$(PKG)_CATEGORY:=Unstable

$(PKG)_TYPES_DB:=$($(PKG)_DIR)/src/types.db
$(PKG)_TARGET_TYPES_DB:=$($(PKG)_DEST_DIR)/usr/share/$(pkg)/types.db

$(PKG)_DEPENDS_ON += libtool
# ensure system libltdl is used and not the included one
$(PKG)_CONFIGURE_PRE_CMDS += $(RM) -r libltdl; sed -i -r -e '/SUBDIRS/ s/libltdl//g' ./Makefile.in;
$(PKG)_CONFIGURE_ENV += LIBLTDL_PREFIX="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"

# remove -Werror flag
$(PKG)_CONFIGURE_PRE_CMDS += sed -i -r -e 's,-Werror,,g' ./configure ./src/Makefile.in ./src/libcollectdclient/Makefile.in ./src/owniptc/Makefile.in;

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --with-nan-emulation
$(PKG)_CONFIGURE_OPTIONS += --with-fp-layout=$(if $(FREETZ_TARGET_ARCH_BE),endianflip,nothing)

$(PKG)_FEATURES_DISABLED := \
    java \
    libcurl \
    libdbi \
    libesmtp libevent \
    libganglia libgcrypt \
    libiokit libiptc \
    libjvm \
    libkstat libkvm \
    libmemcached libmodbus libmysql \
    libnetapp libnetlink libnetsnmp libnotify \
    libopenipmipthread liboping libowcapi \
    libpcap libperfstat libperl libpq \
    librouteros librrd \
    libsensors libstatgrab \
    libtokyotyrant \
    libupsclient \
    libvirt \
    libxml2 libxmms \
    libyajl \
    oracle \
    perl-bindings python
$(PKG)_CONFIGURE_OPTIONS += $(foreach feature,$($(PKG)_FEATURES_DISABLED),--with-$(feature)=no)

ifeq ($(strip $(FREETZ_PACKAGE_COLLECTD_PLUGIN_apache)),y)
$(PKG)_DEPENDS_ON += curl
$(PKG)_CONFIGURE_OPTIONS += --with-libcurl=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr
endif
ifeq ($(strip $(FREETZ_PACKAGE_COLLECTD_PLUGIN_ping)),y)
$(PKG)_DEPENDS_ON += liboping
$(PKG)_CONFIGURE_OPTIONS += --with-liboping=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr
endif
ifeq ($(strip $(FREETZ_PACKAGE_COLLECTD_PLUGIN_rrdtool)),y)
$(PKG)_DEPENDS_ON += rrdtool
$(PKG)_CONFIGURE_OPTIONS += --with-librrd=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr
endif

# plugins
$(PKG)_CONFIGURE_OPTIONS += --disable-all-plugins
$(PKG)_PLUGINS_SUPPORTED := \
    apache \
    contextswitch cpu csv \
    disk df \
    entropy exec \
    fritzbox \
    interface irq \
    load \
    memory \
    network \
    ping \
    rrdtool \
    syslog \
    uptime
$(PKG)_PLUGINS_ENABLED := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_PLUGINS_SUPPORTED),PLUGIN)
$(PKG)_CONFIGURE_OPTIONS += $(foreach plugin,$($(PKG)_PLUGINS_ENABLED),--enable-$(plugin))

$(PKG)_PLUGINS_DIR := $(FREETZ_LIBRARY_DIR)/$(pkg)
$(PKG)_PLUGINS_BUILD_DIR := $($(PKG)_PLUGINS_ENABLED:%=$($(PKG)_DIR)/src/.libs/%.so)
$(PKG)_PLUGINS_TARGET_DIR := $($(PKG)_PLUGINS_ENABLED:%=$($(PKG)_DEST_DIR)$($(PKG)_PLUGINS_DIR)/%.so)

$(PKG)_REBUILD_SUBOPTS += $(foreach plugin,$($(PKG)_PLUGINS_SUPPORTED),FREETZ_PACKAGE_COLLECTD_PLUGIN_$(plugin))

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
