$(call PKG_INIT_BIN, 58cd6b3147)
$(PKG)_SOURCE:=rubyfcgi-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=git@https://github.com/alphallc/ruby-fcgi-ng.git

$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/rubyfcgi-$($(PKG)_VERSION)

$(PKG)_BINARY:=$(RUBY_FCGI_DIR)/lib/fcgi.rb
$(PKG)_TARGET_BINARY:=$(RUBY_FCGI_DEST_DIR)/usr/lib/ruby/$(RUBY_VERSION_SUBDIR)/fcgi.rb

$(PKG)_REBUILD_SUBOPTS += FREETZ_RUBY_SHLIB_VERSION

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:

$(pkg)-uninstall:
	$(RM) $(RUBY_FCGI_TARGET_BINARY)

$(PKG_FINISH)
