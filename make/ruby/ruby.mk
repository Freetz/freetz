$(call PKG_INIT_BIN, 1.8.6)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.xs4all.nl/~hipster/lib/mirror/ruby/1.8
$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)

ifeq ($(FREETZ_TARGET_IPV6_SUPPORT),y)
$(PKG)_CONFIGURE_OPTIONS += --enable-ipv6
else
$(PKG)_CONFIGURE_OPTIONS += --disable-ipv6
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(RUBY_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	mkdir -p $(dir $@)
	$(MAKE) DESTDIR=$(abspath $(RUBY_DEST_DIR)) -C $(RUBY_DIR) install
	rm -rf $(RUBY_DEST_DIR)/usr/{share,lib/*.a,lib/ruby/site_ruby,lib/ruby/1.8/mipsel-linux/*.{h,rb}}
	$(TARGET_STRIP) $@ $(RUBY_DEST_DIR)/usr/lib/ruby/1.8/mipsel-linux/{,*/}*.so

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(RUBY_DIR) clean

$(pkg)-uninstall: 
	$(RM) $(RUBY_TARGET_BINARY)

$(PKG_FINISH)
