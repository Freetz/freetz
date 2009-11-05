$(call PKG_INIT_BIN, 2.4.5git)
$(PKG)_SOURCE:=ppp_2.4.5~git20081126t100229.orig.tar.gz
$(PKG)_SITE:=https://launchpad.net/ubuntu/+archive/primary/+files
$(PKG)_DIR:=$(SOURCE_DIR)/ppp-$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/pppd/pppd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/pppd
$(PKG)_CHAT_BINARY:=$(PPPD_DIR)/chat/chat
$(PKG)_CHAT_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/chat
$(PKG)_STARTLEVEL=40
$(PKG)_SOURCE_MD5:=fadde1f8ffd294fd9c06425ea6bd5cfd

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_PPPD_CHAT

$(PKG)_DEPENDS_ON := libpcap

$(PKG_SOURCE_DOWNLOAD)

$($(PKG)_DIR)/.unpacked: $(DL_DIR)/$($(PKG)_SOURCE) | $(SOURCE_DIR)
	$(RM) -r $($(PKG)_DIR)
	tar -xOf $(DL_DIR)/$(PPPD_SOURCE) ppp-2.4.5git1/upstream/tarballs/$(PPPD_SOURCE) | \
		tar -C $(SOURCE_DIR) $(VERBOSE) -xzf - 
	shopt -s nullglob; for i in $(PPPD_MAKE_DIR)/patches/*.patch; do \
		$(PATCH_TOOL) $(PPPD_DIR) $$i; \
	done
	touch $@

$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) \
	$($(PKG)_CHAT_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" $(MAKE) \
	CC="$(TARGET_CC)" \
	COPTS="$(TARGET_CFLAGS)" \
	STAGING_DIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
	-C $(PPPD_DIR) all

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

# chat
$($(PKG)_CHAT_TARGET_BINARY): $($(PKG)_CHAT_BINARY)
ifeq ($(strip $(FREETZ_PACKAGE_PPPD_CHAT)),y)
	$(INSTALL_BINARY_STRIP)
endif

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) \
			$($(PKG)_CHAT_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(PPPD_DIR) clean

$(pkg)-uninstall:
	$(RM) $(PPPD_TARGET_BINARY) \
		$(PPPD_CHAT_TARGET_BINARY)

$(PKG_FINISH)
