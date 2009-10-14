$(call PKG_INIT_BIN, 5.1)
$(PKG)_SOURCE:=gw6c-$($(PKG)_VERSION).tar.bz2
#$(PKG)_SITE:=http://go6.net/4105/file.asp?file_id=150
$(PKG)_BINARY:=$($(PKG)_DIR)/tspc-advanced/bin/gw6c
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/gw6c
$(PKG)_SOURCE_MD5:=eeac7292a622681651ec3bd9b2e5b061 

$(PKG)_DEPENDS_ON := uclibcxx

GW6C_OPTS:= \
	C_COMPILER="$(TARGET_CC) -c -DNO_STDLIBCXX" \
	COMPILER="$(TARGET_CROSS)g++ -c -DNO_STDLIBCXX" \
	CPP_FLAGS="$(TARGET_CFLAGS) -fno-builtin -nostdinc++ -I. -Wall -DNDEBUG \
		-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/uClibc++" \
	RANLIB="$(TARGET_CROSS)ranlib" \
	ARCHIVER="$(TARGET_CROSS)ar" \
	C_LINKER="$(TARGET_CC)" \
	LINKER="$(TARGET_CROSS)g++"


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)


$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(GW6_DIR)/gw6c-config \
		$(GW6C_OPTS)
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(GW6_DIR)/gw6c-messaging \
		$(GW6C_OPTS)
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(GW6_DIR)/tspc-advanced \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -fno-builtin -Wall -I../../include -I../../platform/openwrt -I../.." \
		LDFLAGS="-L../../gw6cconfig -L../../gw6cmessaging -nodefaultlibs -luClibc++ -lgcc_s -lpthread" \
		target="openwrt"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(GW6_DIR)/tspc-advanced target=openwrt clean
	-$(MAKE) -C $(GW6_DIR)/gw6c-config target=openwrt clean
	-$(MAKE) -C $(GW6_DIR)/gw6c-messaging target=openwrt clean

$(pkg)-uninstall:
	$(RM) $($(PKG)_TARGET_BINARY)

$(PKG_FINISH)
