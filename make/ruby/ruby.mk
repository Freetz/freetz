$(call PKG_INIT_BIN, 1.8.6-p368)
$(PKG)_MAJOR_VERSION:=$(call GET_MAJOR_VERSION,$($(PKG)_VERSION))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=508bf1911173ac43e4e6c31d9dc36b8f
$(PKG)_SITE:=ftp://ftp.ruby-lang.org/pub/ruby/$($(PKG)_MAJOR_VERSION)

$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_BUILD_PREREQ += ruby:$(RUBY_MAJOR_VERSION)
$(PKG)_BUILD_PREREQ_HINT := Hint: on Debian-like systems the required files are provided by the package ruby$(RUBY_MAJOR_VERSION)

$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --enable-wide-getaddrinfo
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(RUBY_DIR) all

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	mkdir -p $(dir $@)
	$(SUBMAKE) DESTDIR=$(abspath $(RUBY_DEST_DIR)) -C $(RUBY_DIR) install
	$(RM) -r $(RUBY_DEST_DIR)/usr/{share,lib/*.a,lib/ruby/site_ruby,lib/ruby/$(RUBY_MAJOR_VERSION)/$(GNU_TARGET_NAME)/*.{h,rb}}
	$(TARGET_STRIP) $@ $(RUBY_DEST_DIR)/usr/lib/ruby/$(RUBY_MAJOR_VERSION)/$(GNU_TARGET_NAME)/{,*/}*.so

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(RUBY_DIR) clean

$(pkg)-uninstall:
	$(RM) $(RUBY_TARGET_BINARY)

$(PKG_FINISH)
