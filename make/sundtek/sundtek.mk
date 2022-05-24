SUNDTEK_SITE:=http://www.sundtek.de/media

define sundtek-get-latest-version
$(shell ver=$$(wget -q $(SUNDTEK_SITE)/latest.phtml -O - 2>/dev/null | sed -rn 's/.*sundtek_installer_([0-9\.]*)\.sh.*/\1/p'); echo "$${ver:-FAILED_TO_DETERMINE_LATEST_VERSION}")
endef

$(call PKG_INIT_BIN,$(if $(FREETZ_PACKAGE_SUNDTEK_VERSION_LATEST),$(call sundtek-get-latest-version),$(if $(FREETZ_PACKAGE_SUNDTEK_VERSION_2013),130210.134617,$(if $(FREETZ_PACKAGE_SUNDTEK_VERSION_2017),170310.204343,210803.071224))))
$(PKG)_SOURCE:=$(pkg)_installer_$($(PKG)_VERSION).sh
$(PKG)_HASH_130210.134617:=ba18d6cc682dcb2be1968a7ca83f9c381246acc54210751145c2a5dc205e0c94
$(PKG)_HASH_170310.204343:=602e976bca8022255535efff4ede62b0d0f5e7f4a54a758fb8cb7cdad8c53e90
$(PKG)_HASH_210803.071224:=e5f827f7d96e19e5ade931a6889e46adb69debadb9c02f56ca14a85a1049e5be
$(PKG)_HASH:=$($(PKG)_HASH_$($(PKG)_VERSION))

$(PKG)_ARCH:=$(or $(call qstrip,$(FREETZ_PACKAGE_SUNDTEK_ARCH)),undefined)

$(PKG)_STARTLEVEL=90 # before rrdstats

$(PKG)_BINARIES            := mediasrv mediaclient
$(PKG)_BINARIES_BUILD_DIR  := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/opt/bin/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/sundtek-%)

$(PKG)_LIBS                := libmediaclient.so
$(PKG)_LIBS_BUILD_DIR      := $($(PKG)_LIBS:%=$($(PKG)_DIR)/opt/lib/%)
$(PKG)_LIBS_TARGET_DIR     := $($(PKG)_LIBS:lib%=$($(PKG)_DEST_DIR)/usr/lib/libsundtek%)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SUNDTEK_ARCH
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SUNDTEK_VERSION_2013
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SUNDTEK_VERSION_2017
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SUNDTEK_VERSION_2021
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SUNDTEK_VERSION_LATEST

$(PKG)_BUILD_PREREQ += dd

define $(PKG)_CUSTOM_UNPACK
	mkdir -p $($(PKG)_DIR); \
	payload="$$$$(cat $(1) | sed -rn 's!^_SIZE=(.*)!\1!p')"; \
	dd if=$(strip $(1)) skip=1 bs=$$$$payload  | \
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
