$(call TOOLS_INIT, 20130503)
$(PKG)_SOURCE:=prelink-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=6339c7605e9b6f414d1be32530c9c8011f38820d36431c8a62e8674ca37140f0
$(PKG)_SITE:=https://people.redhat.com/jakub/prelink
### WEBSITE:=https://people.redhat.com/jakub/prelink/
### MANPAGE:=https://people.redhat.com/jakub/prelink/prelink.pdf
### CHANGES:=https://packages.debian.org/buster/execstack

$(PKG)_BINARY:=$($(PKG)_DIR)/src/execstack
$(PKG)_TARGET_BINARY:=$(TOOLS_DIR)/execstack

# fakeroot & pseudo cant handle selinux
$(PKG)_CONFIGURE_ENV += ac_cv_lib_selinux_is_selinux_enabled=no


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(PRELINK_HOST_DIR) \
		prelink_LDFLAGS="" \
		all

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(MAKE) -C $(PRELINK_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(PRELINK_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(PRELINK_HOST_TARGET_BINARY)

$(TOOLS_FINISH)
