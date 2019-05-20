$(call PKG_INIT_BIN, 3.0.28)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION)-stable-src.tar.gz
$(PKG)_SOURCE_MD5:=c7e8900d5aff33d9a5fc37ac28154f21
$(PKG)_SITE:=@SF/ijbswa

$(PKG)_BINARY:=$($(PKG)_DIR)/privoxy
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/privoxy

$(PKG)_CONFIGURE_PRE_CMDS += autoheader;
$(PKG)_CONFIGURE_PRE_CMDS += autoconf;

ifeq ($(strip $(FREETZ_PACKAGE_PRIVOXY_WITH_SHARED_PCRE)),y)
$(PKG)_DEPENDS_ON += pcre
endif

ifeq ($(strip $(FREETZ_PACKAGE_PRIVOXY_WITH_ZLIB)),y)
$(PKG)_DEPENDS_ON += zlib
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PRIVOXY_WITH_SHARED_PCRE
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PRIVOXY_WITH_ZLIB
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/mod/etc
$(PKG)_CONFIGURE_OPTIONS += --with-docbook=no
$(PKG)_CONFIGURE_OPTIONS += --disable-stats
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_PRIVOXY_WITH_SHARED_PCRE),,--disable-dynamic-pcre)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_PRIVOXY_WITH_ZLIB),--enable-zlib,--disable-zlib)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6-support,--disable-ipv6-support)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(PRIVOXY_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)
	mkdir -p $(PRIVOXY_DEST_DIR)/etc/privoxy/templates; \
	for s in $$(find $(PRIVOXY_DIR)/templates/ -type f); do \
		d=$$(basename $$s); \
		egrep -v "^#\ " $$s | egrep -v "^#*$$" >$(PRIVOXY_DEST_DIR)/etc/privoxy/templates/$$d || true; \
	done; \
	for s in \
		$(PRIVOXY_DIR)/default.filter \
		$(PRIVOXY_DIR)/default.action \
		$(PRIVOXY_DIR)/match-all.action \
		$(PRIVOXY_DIR)/user.action \
		$(PRIVOXY_DIR)/user.filter \
	; do \
		d=$$(basename $$s); \
		egrep -v "^#" $$s | egrep -v "^$$" >$(PRIVOXY_DEST_DIR)/etc/privoxy/$$d || true; \
	done

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(PRIVOXY_DIR) clean

$(pkg)-uninstall:
	$(RM) -r $(PRIVOXY_TARGET_BINARY) $(PRIVOXY_DEST_DIR)/etc/privoxy

$(PKG_FINISH)
