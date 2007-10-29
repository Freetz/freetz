PACKAGE_LC:=ruby
PACKAGE_UC:=RUBY
$(PACKAGE_UC)_VERSION:=1.8.6
$(PACKAGE_INIT_BIN)
$(PACKAGE_UC)_SOURCE:=ruby-$($(PACKAGE_UC)_VERSION).tar.bz2
$(PACKAGE_UC)_SITE:=ftp://ftp.ruby-lang.org/pub/ruby/1.8
$(PACKAGE_UC)_BINARY:=$($(PACKAGE_UC)_DIR)/ruby
$(PACKAGE_UC)_TARGET_BINARY:=$($(PACKAGE_UC)_DEST_DIR)/usr/bin/ruby

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)
$(PACKAGE_UC)_CONFIGURE_PRE_CMDS:=autoreconf;
$(PACKAGE_CONFIGURED_CONFIGURE)

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(RUBY_DIR)

$($(PACKAGE_UC)_TARGET_BINARY): $($(PACKAGE_UC)_BINARY)
	mkdir -p $(dir $@)
	$(MAKE) DESTDIR=$(abspath $(RUBY_DEST_DIR)) -C $(RUBY_DIR) install
	rm -rf $(RUBY_DEST_DIR)/usr/{share,lib/*.a,lib/ruby/site_ruby,lib/ruby/1.8/mipsel-linux/*.{h,rb}}
	$(TARGET_STRIP) $@ $(RUBY_DEST_DIR)/usr/lib/ruby/1.8/mipsel-linux/{,*/}*.so

ruby:

ruby-precompiled: uclibc ruby $($(PACKAGE_UC)_TARGET_BINARY)

ruby-clean:
	-$(MAKE) -C $(RUBY_DIR) clean

ruby-uninstall: 
	rm -rf $(RUBY_TARGET_DIR)/root/*

$(PACKAGE_FINI)
