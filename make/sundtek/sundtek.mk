$(call PKG_INIT_BIN,121113.174818)
$(PKG)_SOURCE:=sundtek_installer_$($(PKG)_VERSION).sh
$(PKG)_SOURCE_MD5:=fdc3d8d1abb3213a759ce73fa2e83136
$(PKG)_SOURCE_DIR:=$(SOURCE_DIR)/$(pkg)-$($(PKG)_VERSION)
$(PKG)_SITE:=http://www.sundtek.de/media/

$(PKG)_STARTLEVEL=90 # before rrdstats

$(PKG)_BINARIES_ALL := mediasrv mediaclient libmediaclient.so
$(PKG)_BINARIES_PATH := bin/ bin/ lib/
$(PKG)_BINARIES := $(join $($(PKG)_BINARIES_PATH),$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/opt/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/%)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_DIR)/.unpacked:
	payload="$$(cat $(DL_DIR)/$(SUNDTEK_SOURCE) | sed -rn 's!^_SIZE=(.*)!\1!p')" ;\
	dd if=$(DL_DIR)/$(SUNDTEK_SOURCE) skip=1 bs=$$payload |\
	 tar Oxz $(if $(FREETZ_TARGET_ARCH_LE),mipselbcm,openwrtmipsr2)/installer.tar.gz |\
	 tar xz -C $(SUNDTEK_DIR)
	@touch $@

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.unpacked
	@chmod 755 $(SUNDTEK_BINARIES_BUILD_DIR)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/%: $($(PKG)_DIR)/opt/%
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:

$(PKG_FINISH)

