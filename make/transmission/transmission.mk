$(call PKG_INIT_BIN, 1.92)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=561357621331f294c87f78e22783a283
$(PKG)_SITE:=http://download.m0k.org/transmission/files

$(PKG)_BINARIES_ALL := transmissioncli transmission-daemon transmission-remote
$(PKG)_BINARIES := $(if $(FREETZ_PACKAGE_TRANSMISSION_CLIENT),transmissioncli,) $(if $(FREETZ_PACKAGE_TRANSMISSION_DAEMON),transmission-daemon,) $(if $(FREETZ_PACKAGE_TRANSMISSION_REMOTE),transmission-remote,)
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/daemon/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)
$(PKG)_WEBINTERFACE_DIR:=$($(PKG)_DIR)/web
$(PKG)_TARGET_WEBINTERFACE_DIR:=$($(PKG)_DEST_DIR)/usr/share/transmission-web-home
$(PKG)_TARGET_WEBINTERFACE_INDEX_HTML:=$($(PKG)_TARGET_WEBINTERFACE_DIR)/index.html

$(PKG)_NOT_INCLUDED := $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))
ifneq ($(strip $(FREETZ_PACKAGE_TRANSMISSION_WEBINTERFACE)),y)
$(PKG)_NOT_INCLUDED += $($(PKG)_TARGET_WEBINTERFACE_DIR)
endif

$(PKG)_DEPENDS_ON := zlib openssl curl libevent

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TRANSMISSION_STATIC

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
# remove optimization & debug flags
$(PKG)_CONFIGURE_PRE_CMDS += $(foreach flag,-O[0-9] -g -ggdb3,$(SED) -i -r -e 's,(C(XX)?FLAGS="[^"]*)$(flag)(( [^"]*)?"),\1\3,g' ./configure;)

$(PKG)_CONFIGURE_OPTIONS += --disable-beos
$(PKG)_CONFIGURE_OPTIONS += --disable-mac
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk
$(PKG)_CONFIGURE_OPTIONS += --disable-wx
$(PKG)_CONFIGURE_OPTIONS += --disable-silent-rules

ifeq ($(strip $(FREETZ_PACKAGE_TRANSMISSION_STATIC)),y)
$(PKG)_LDFLAGS := -all-static
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(TRANSMISSION_DIR) \
		LDFLAGS="$(TARGET_LDFLAGS) $(TRANSMISSION_LDFLAGS)" \
		&& cp $(TRANSMISSION_DIR)/cli/transmissioncli $(TRANSMISSION_DIR)/daemon/

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/daemon/%
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_WEBINTERFACE_INDEX_HTML): $($(PKG)_DIR)/.unpacked
ifeq ($(strip $(FREETZ_PACKAGE_TRANSMISSION_WEBINTERFACE)),y)
	mkdir -p $(TRANSMISSION_TARGET_WEBINTERFACE_DIR)
	tar -c -C $(TRANSMISSION_WEBINTERFACE_DIR) --exclude=.svn --exclude=LICENSE --exclude='Makefile*' . | tar -x -C $(TRANSMISSION_TARGET_WEBINTERFACE_DIR)
	# remove all non-min.js files, these are not needed
	for f in $(TRANSMISSION_TARGET_WEBINTERFACE_DIR)/javascript/jquery/*.js; do if ! (echo "$$f" | grep -q '\.min\.js$$' >/dev/null 2>&1); then $(RM) "$$f"; fi; done
	chmod 644 $(TRANSMISSION_TARGET_WEBINTERFACE_INDEX_HTML)
	touch $@
endif

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR) $($(PKG)_TARGET_WEBINTERFACE_INDEX_HTML)

$(pkg)-clean:
	-$(SUBMAKE) -C $(TRANSMISSION_DIR) clean

$(pkg)-uninstall:
	$(RM) -r \
		$(TRANSMISSION_BINARIES_ALL:%=$(TRANSMISSION_DEST_DIR)/usr/bin/%) \
		$(TRANSMISSION_TARGET_WEBINTERFACE_DIR)

$(PKG_FINISH)
