$(call PKG_INIT_BIN, 0.5)
#:wq064bfc3)
$(PKG)_SOURCE:=$($(PKG)_VERSION).tar.gz
#$(PKG)_SOURCE_MD5:=f3adf5417504e27f3ac84a2d1fba921b
$(PKG)_SITE:=https://github.com/ShadowsocksR-Live/shadowsocksr-native/archive/

$(PKG)_BINARY:=$($(PKG)_DIR)/src/ssr-server
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/ssr-server


$(PKG)_DEPENDS_ON += mbedtls libz libpcre libuv libsodium libjson-c

$(PKG)_STARTLEVEL=90

$(PKG)_EXTRA_CFLAGS += --function-sections -fdata-sections
$(PKG)_EXTRA_LDFLAGS += -Wl,--gc-sections

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$(pkg)-cmake: $(SHADOWSOCKSR_DIR)/.unpacked
	$(SED) -i "s|add_subdirectory(depends|#add_subdirectory(depends|g" $(SHADOWSOCKSR_DIR)/CMakeLists.txt
	cd $(SHADOWSOCKSR_DIR) && $(MAKE_ENV) cmake \
		-DCMAKE_C_COMPILER="$(TARGET_CC)"  \
		-DCMAKE_CXX_COMPILER="$(TARGET_CXX)"  \
		-DCMAKE_PREFIX_PATH="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		-DCMAKE_C_FLAGS="$(TARGET_CFLAGS) $(SHADOWSOCKSR_EXTRA_CFLAGS)" \
		-DCMAKE_LD_FLAGS="$(TARGET_LDFLAGS) $(SHADOWSOCKSR_EXTRA_LDFLAGS)" \
		-DCMAKE_VERBOSE_MAKEFILE:BOOL=ON

$($(PKG)_BINARY): $($(PKG)_DIR)/.unpacked $(pkg)-cmake
	$(SUBMAKE) -C $(SHADOWSOCKSR_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SHADOWSOCKSR_DIR) clean

$(pkg)-uninstall:
	$(RM) $(SHADOWSOCKSR_TARGET_BINARY) 

$(PKG_FINISH)
