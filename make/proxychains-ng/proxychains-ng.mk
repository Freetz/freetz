PROXYCHAINS_NG_GIT_REPOSITORY:=https://github.com/rofl0r/proxychains-ng.git
$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_PROXYCHAINS_NG_VERSION_LATEST), $(call git-get-latest-revision,$(PROXYCHAINS_NG_GIT_REPOSITORY),), $(if $(FREETZ_PACKAGE_PROXYCHAINS_NG_VERSION_CUSTOM), $(shell echo "$(FREETZ_PACKAGE_PROXYCHAINS_NG_VERSION_COMMIT)"), e895fb713a) ))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=X
$(PKG)_SITE:=git@$($(PKG)_GIT_REPOSITORY)
#$(PKG)_SITE:=https://github.com/haad/proxychains/archive/refs/tags
### WEBSITE:=http://proxychains.sourceforge.net
### MANPAGE:=https://github.com/haad/proxychains#readme
### CHANGES:=https://github.com/haad/proxychains/tags
### CVSREPO:=https://github.com/haad/proxychains

$(PKG)_BINARY:=$($(PKG)_DIR)/proxychains4
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/proxychains4

$(PKG)_MODULE:=$($(PKG)_DIR)/libproxychains4.so
$(PKG)_TARGET_MODULE := $($(PKG)_DEST_LIBDIR)/libproxychains4.so

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PROXYCHAINS_NG_VERSION_STABLE
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PROXYCHAINS_NG_VERSION_LATEST
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PROXYCHAINS_NG_VERSION_CUSTOM
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PROXYCHAINS_NG_VERSION_COMMIT

$(PKG)_CONFIGURE_OPTIONS += --libdir="$(FREETZ_RPATH)"


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_MODULE): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(PROXYCHAINS_NG_DIR) \
		CC=$(TARGET_CC) \
		STRIP="$(TARGET_STRIP)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_MODULE): $($(PKG)_MODULE)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_MODULE)


$(pkg)-clean:
	-$(SUBMAKE) -C $(PROXYCHAINS_NG_DIR) clean

$(pkg)-uninstall:
	$(RM) $(PROXYCHAINS_NG_TARGET_BINARY) $(PROXYCHAINS_NG_TARGET_MODULE)

$(PKG_FINISH)

