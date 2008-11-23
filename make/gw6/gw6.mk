$(call PKG_INIT_BIN, 5.1)
$(PKG)_SOURCE:=gw6c-5_1-RELEASE-src.tar.gz
$(PKG)_SITE:=http://go6.net/4105/file.asp?file_id=150
$(PKG)_DIR:=$(SOURCE_DIR)/tspc-advanced
$(PKG)_BINARY:=$($(PKG)_DIR)/bin/gw6c
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/gw6c


### PKG_SOURCE_DOWNLOAD
int_gwsix_source:=$($(PKG)_SOURCE)
int_gwsix_site:=$($(PKG)_SITE)
$(DL_DIR)/$($(PKG)_SOURCE): | $(DL_DIR)
	@if [ -e $(MIRROR_DIR)/$(int_gwsix_source) ]; then \
		echo "Found $(int_gwsix_source) in $(MIRROR_DIR), creating hard link"; \
		ln $(MIRROR_DIR)/$(int_gwsix_source) $(DL_DIR); \
	else \
		wget -O $(DL_DIR)/$(int_gwsix_source) $(int_gwsix_site); \
	fi

$(pkg)-download: $(DL_DIR)/$($(PKG)_SOURCE)

$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)


$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(GW6_DIR) all \
		target=linux \
		CC="$(TARGET_CC)" \
		CXX="$(TARGET_MAKE_PATH)/$(TARGET_CROSS)c++" \
		AR="$(TARGET_MAKE_PATH)/$(TARGET_CROSS)ar" \
		RANLIB="$(TARGET_MAKE_PATH)/$(TARGET_CROSS)ranlib"
		
		
		
$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(GW6_DIR) target=linux clean
	-$(MAKE) -C $(SOURCE_DIR)/gw6c-config target=linux clean
	-$(MAKE) -C $(SOURCE_DIR)/gw6c-messaging target=linux clean

$(pkg)-uninstall:
	$(RM) $($(PKG)_TARGET_BINARY)

$(PKG_FINISH)
