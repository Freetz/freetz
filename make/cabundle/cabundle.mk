CABUNDLE_GIT_REPOSITORY:=https://github.com/bagder/ca-bundle.git
$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_CABUNDLE_VERSION_LATEST), $(call git-get-latest-revision,$(CABUNDLE_GIT_REPOSITORY),), $(if $(FREETZ_PACKAGE_CABUNDLE_VERSION_CUSTOM), $(shell echo "$(FREETZ_PACKAGE_CABUNDLE_VERSION_COMMIT)"), 1) ))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SITE:=git@$($(PKG)_GIT_REPOSITORY)

$(PKG)_BINARY:=$($(PKG)_DIR)/ca-bundle.crt
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/etc/ssl/certs/ca-bundle.crt

$(PKG)_BUILD_PREREQ += git
$(PKG)_BUILD_PREREQ_HINT := Hint: on Debian-like systems this binary is provided by the git package (sudo apt-get install git)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_CABUNDLE_VERSION_LATEST
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_CABUNDLE_VERSION_CUSTOM
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_CABUNDLE_VERSION_COMMIT

$(PKG)_STARTLEVEL=30

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
	$(RM) $(CABUNDLE_TARGET_BINARY)

$(PKG_FINISH)
