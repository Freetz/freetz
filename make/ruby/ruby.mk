$(call PKG_INIT_BIN, $(if $(FREETZ_RUBY_VERSION_1_8),1.8.7-p374,1.9.3-p547))
$(PKG)_MAJOR_VERSION:=$(call GET_MAJOR_VERSION,$($(PKG)_VERSION))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5_1.8:=83c92e2b57ea08f31187060098b2200b
$(PKG)_SOURCE_MD5_1.9:=5363d399be7f827c77bf8ae5d1a69b38
$(PKG)_SOURCE_MD5:=$($(PKG)_SOURCE_MD5_$($(PKG)_MAJOR_VERSION))
$(PKG)_SITE:=ftp://ftp.ruby-lang.org/pub/ruby/$($(PKG)_MAJOR_VERSION)

$(PKG)_CONDITIONAL_PATCHES+=$($(PKG)_MAJOR_VERSION)

$(PKG)_SHLIB_VERSION:=$(call qstrip,$(FREETZ_RUBY_SHLIB_VERSION))
$(PKG)_VERSION_WITHOUT_PATCHLEVEL:=$(firstword $(subst -,$(_space),$($(PKG)_VERSION)))
$(PKG)_VERSION_SUBDIR:=$(if $(FREETZ_RUBY_VERSION_1_8),$($(PKG)_MAJOR_VERSION),$($(PKG)_SHLIB_VERSION))

$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_BUILD_PREREQ += ruby:$($(PKG)_VERSION_WITHOUT_PATCHLEVEL)
$(PKG)_BUILD_PREREQ_HINT := Hint: on Debian-like systems the required files are provided either by the package ruby$($(PKG)_VERSION_WITHOUT_PATCHLEVEL) or ruby$($(PKG)_MAJOR_VERSION)

$(PKG)_REBUILD_SUBOPTS += FREETZ_RUBY_VERSION_1_8
$(PKG)_REBUILD_SUBOPTS += FREETZ_RUBY_VERSION_1_9
$(PKG)_REBUILD_SUBOPTS += FREETZ_RUBY_SHLIB_VERSION
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
	$(RM) -r $(RUBY_DEST_DIR)/{usr/{include,share,lib/*.a,lib/pkgconfig,lib/ruby/site_ruby,lib/ruby/$(RUBY_VERSION_SUBDIR)/$(GNU_TARGET_NAME)/*.{h,rb}},var}
	$(TARGET_STRIP) $@ $(RUBY_DEST_DIR)/usr/lib/ruby/$(RUBY_VERSION_SUBDIR)/$(GNU_TARGET_NAME)/{,*/}*.so

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(RUBY_DIR) clean

$(pkg)-uninstall:
	$(RM) $(RUBY_TARGET_BINARY)

$(PKG_FINISH)
