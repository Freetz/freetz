PACKAGE_LC:=ruby
PACKAGE_UC:=RUBY
RUBY_VERSION:=1.8.6
RUBY_SOURCE:=ruby-$(RUBY_VERSION).tar.bz2
RUBY_SITE:=ftp://ftp.ruby-lang.org/pub/ruby/1.8
RUBY_DIR:=$(SOURCE_DIR)/ruby-$(RUBY_VERSION)
RUBY_MAKE_DIR:=$(MAKE_DIR)/ruby
RUBY_BINARY:=$(RUBY_DIR)/ruby
RUBY_TARGET_DIR:=$(PACKAGES_DIR)/ruby-$(RUBY_VERSION)
RUBY_TARGET_BINARY:=$(RUBY_TARGET_DIR)/root/usr/bin/ruby
RUBY_STARTLEVEL=99

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_BIN_UNPACKED)
$(PACKAGE_UC)_CONFIGURE_PRE_CMDS:=autoreconf;
$(PACKAGE_CONFIGURED_CONFIGURE)

$(RUBY_BINARY): $(RUBY_DIR)/.configured
	PATH="$(TARGET_PATH)" make -C $(RUBY_DIR)

$(RUBY_TARGET_BINARY): $(RUBY_BINARY)
	mkdir -p $(dir $(RUBY_TARGET_BINARY))
	$(MAKE) DESTDIR=$(abspath $(RUBY_TARGET_DIR))/root -C $(RUBY_DIR) install
	rm -rf $(RUBY_TARGET_DIR)/root/usr/{share,lib/*.a,lib/ruby/site_ruby,lib/ruby/1.8/mipsel-linux/*.{h,rb}}
	$(TARGET_STRIP) $@ $(RUBY_TARGET_DIR)/root/usr/lib/ruby/1.8/mipsel-linux/{,*/}*.so

ruby:

ruby-precompiled: uclibc ruby $(RUBY_TARGET_BINARY)

ruby-source: $(RUBY_DIR)/.unpacked

ruby-clean:
	-$(MAKE) -C $(RUBY_DIR) clean

ruby-dirclean:
	rm -rf $(RUBY_DIR)
	rm -rf $(RUBY_TARGET_DIR)

ruby-uninstall: 
	rm -rf $(RUBY_TARGET_DIR)/root/*

$(PACKAGE_LIST)
