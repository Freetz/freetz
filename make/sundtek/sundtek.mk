SUNDTEK_SITE:=http://www.sundtek.de/media
SUNDTEK_INSTALLER_PATTERN:=$(SUNDTEK_SITE)/sundtek_installer_([0-9]{6}[.][0-9]{6})[.]sh

define sundtek-get-latest-version
$(shell ver=$$(wget -q $(SUNDTEK_SITE) -O - 2>/dev/null | grep -Eo '$(SUNDTEK_INSTALLER_PATTERN)' | sed -rne 's,$(SUNDTEK_INSTALLER_PATTERN),\1,p' | sort -u | tail -n 1); echo "$${ver:-FAILED_TO_DETERMINE_LATEST_VERSION}")
endef

$(call PKG_INIT_BIN,$(if $(FREETZ_PACKAGE_SUNDTEK_VERSION_LATEST),$(call sundtek-get-latest-version),$(if $(FREETZ_PACKAGE_SUNDTEK_VERSION_2013),130210.134617,170310.204343)))
$(PKG)_SOURCE:=$(pkg)_installer_$($(PKG)_VERSION).sh
$(PKG)_SOURCE_MD5_130210.134617:=81451e57207ad2d3e8c6e148be110040
$(PKG)_SOURCE_MD5_170310.204343:=f3001a7a45e558aab2e98e7b3a84ff6d
$(PKG)_SOURCE_MD5:=$($(PKG)_SOURCE_MD5_$($(PKG)_VERSION))

$(PKG)_ARCH:=$(or $(call qstrip,$(FREETZ_PACKAGE_SUNDTEK_ARCH)),undefined)

$(PKG)_STARTLEVEL=90 # before rrdstats

$(PKG)_BINARIES            := mediasrv mediaclient
$(PKG)_BINARIES_BUILD_DIR  := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/opt/bin/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/sundtek-%)

$(PKG)_LIBS                := libmediaclient.so
$(PKG)_LIBS_BUILD_DIR      := $($(PKG)_LIBS:%=$($(PKG)_DIR)/opt/lib/%)
$(PKG)_LIBS_TARGET_DIR     := $($(PKG)_LIBS:lib%=$($(PKG)_DEST_DIR)/usr/lib/libsundtek%)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SUNDTEK_VERSION_2013
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SUNDTEK_VERSION_2017
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SUNDTEK_VERSION_LATEST

$(PKG)_BUILD_PREREQ += dd

define $(PKG)_CUSTOM_UNPACK
	mkdir -p $($(PKG)_DIR); \
	payload="$$$$(cat $(1) | sed -rn 's!^_SIZE=(.*)!\1!p')"; \
	dd if=$(1) skip=1 bs=$$$$payload 2>/dev/null | \
	$(TAR) Oxz $($(PKG)_ARCH)/installer.tar.gz | \
	$(TAR) xz -C $($(PKG)_DIR)
endef

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR) $($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	@chmod 755 $@

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/sundtek-%: $($(PKG)_DIR)/opt/bin/%
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/lib/libsundtek%: $($(PKG)_DIR)/opt/lib/lib%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR) $($(PKG)_LIBS_TARGET_DIR)

$(pkg)-clean:

$(PKG_FINISH)
