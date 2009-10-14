$(call PKG_INIT_BIN, 0.8.7)
$(PKG)_SOURCE:=ruby-fcgi-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.moonwolf.com/ruby/archive
$(PKG)_BINARY:=$(RUBY_FCGI_DIR)/lib/fcgi.rb
$(PKG)_TARGET_BINARY:=$(RUBY_FCGI_DEST_DIR)/usr/lib/ruby/1.8/fcgi.rb
$(PKG)_SOURCE_MD5:=fe4d4a019785e8108668a3e81a5df5e1 

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	mkdir -p $(dir $@)
	cp $^ $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:

$(pkg)-uninstall: 
	$(RM) $(RUBY_FCGI_TARGET_BINARY)

$(PKG_FINISH)
