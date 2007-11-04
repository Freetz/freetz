$(call PKG_INIT_BIN, 4.5.15)
$(PKG)_SOURCE:=strace-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://mesh.dl.sourceforge.net/sourceforge/strace
$(PKG)_BINARY:=$($(PKG)_DIR)/strace
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/strace


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(STRACE_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

strace:

strace-precompiled: uclibc strace $($(PKG)_TARGET_BINARY)

strace-clean:
	-$(MAKE) -C $(STRACE_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(STRACE_PKG_SOURCE)

strace-uninstall:
	rm -f $(STRACE_TARGET_BINARY)
	
$(PKG_FINISH)