$(call PKG_INIT_BIN, 1.50b4)
$(PKG)_SOURCE:=transmission-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://download.m0k.org/transmission/files
$(PKG)_CLIENT_BINARY:=$($(PKG)_DIR)/cli/transmissioncli
$(PKG)_TARGET_CLIENT_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/transmissioncli
$(PKG)_DAEMON_BINARY:=$($(PKG)_DIR)/daemon/transmission-daemon
$(PKG)_TARGET_DAEMON_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/transmission-daemon
$(PKG)_REMOTE_BINARY:=$($(PKG)_DIR)/daemon/transmission-remote
$(PKG)_TARGET_REMOTE_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/transmission-remote
$(PKG)_WEBINTERFACE_DIR:=$($(PKG)_DIR)/web
$(PKG)_TARGET_WEBINTERFACE_DIR:=$($(PKG)_DEST_DIR)/usr/share/transmission-web-home
$(PKG)_TARGET_WEBINTERFACE_INDEX_HTML:=$($(PKG)_TARGET_WEBINTERFACE_DIR)/index.html

$(PKG)_DEPENDS_ON := zlib openssl curl

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_TRANSMISSION_STATIC

$(PKG)_CONFIGURE_ENV += PKG_CONFIG_PATH="$(TARGET_MAKE_PATH)/../usr/lib/pkgconfig"

$(PKG)_CONFIGURE_OPTIONS += --disable-beos
$(PKG)_CONFIGURE_OPTIONS += --disable-mac
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk
$(PKG)_CONFIGURE_OPTIONS += --disable-wx

ifeq ($(strip $(FREETZ_PACKAGE_TRANSMISSION_STATIC)),y)
TRANSMISSION_LDFLAGS := -all-static
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_CLIENT_BINARY) $($(PKG)_DAEMON_BINARY) $($(PKG)_REMOTE_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(TRANSMISSION_DIR) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CXXFLAGS="$(TARGET_CXXFLAGS)" \
		CPPFLAGS="$(TARGET_CXXFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS) $(TRANSMISSION_LDFLAGS)"

$($(PKG)_TARGET_CLIENT_BINARY): $($(PKG)_CLIENT_BINARY)
ifeq ($(strip $(FREETZ_PACKAGE_TRANSMISSION_CLIENT)),y)
	$(INSTALL_BINARY_STRIP)
endif

$($(PKG)_TARGET_DAEMON_BINARY): $($(PKG)_DAEMON_BINARY)
ifeq ($(strip $(FREETZ_PACKAGE_TRANSMISSION_DAEMON)),y)
	$(INSTALL_BINARY_STRIP)
endif

$($(PKG)_TARGET_REMOTE_BINARY): $($(PKG)_REMOTE_BINARY)
ifeq ($(strip $(FREETZ_PACKAGE_TRANSMISSION_REMOTE)),y)
	$(INSTALL_BINARY_STRIP)
endif

$($(PKG)_TARGET_WEBINTERFACE_INDEX_HTML): $($(PKG)_DIR)/.unpacked
ifeq ($(strip $(FREETZ_PACKAGE_TRANSMISSION_WEBINTERFACE)),y)
	mkdir -p $(TRANSMISSION_TARGET_WEBINTERFACE_DIR)
	cp -a $(TRANSMISSION_WEBINTERFACE_DIR)/* $(TRANSMISSION_TARGET_WEBINTERFACE_DIR)/
	# we do respect the license, but delete it as it just takes place in the firmware
	$(RM) $(TRANSMISSION_TARGET_WEBINTERFACE_DIR)/LICENSE
	# remove all non-min.js files, these are not needed	
	for f in $(TRANSMISSION_TARGET_WEBINTERFACE_DIR)/javascript/jquery/*.js; do if ! (echo "$$f" | grep -q '\.min\.js$$' >/dev/null 2>&1); then $(RM) "$$f"; fi; done
	chmod 644 $(TRANSMISSION_TARGET_WEBINTERFACE_INDEX_HTML)
endif
ifneq ($(strip $(FREETZ_PACKAGE_TRANSMISSION_WEBINTERFACE)),y)
	$(RM) -r $(TRANSMISSION_DEST_DIR)/usr/share
endif

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_CLIENT_BINARY) $($(PKG)_TARGET_DAEMON_BINARY) \
			$($(PKG)_TARGET_REMOTE_BINARY) $($(PKG)_TARGET_WEBINTERFACE_INDEX_HTML)

$(pkg)-clean:
	-$(MAKE) -C $(TRANSMISSION_DIR) clean

$(pkg)-uninstall:
	$(RM) -r $(TRANSMISSION_TARGET_CLIENT_BINARY) \
		$(TRANSMISSION_TARGET_DAEMON_BINARY) \
		$(TRANSMISSION_TARGET_REMOTE_BINARY) \
		$(TRANSMISSION_TARGET_WEBINTERFACE_DIR)

$(PKG_FINISH)
