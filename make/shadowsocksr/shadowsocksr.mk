$(call PKG_INIT_BIN, 064bfc3522d2f887586bb71c67ffacd0c94ceb56)
$(PKG)_SOURCE:=$($(PKG)_VERSION).tar.gz
#$(PKG)_SOURCE_MD5:=f3adf5417504e27f3ac84a2d1fba921b
$(PKG)_SITE:=https://github.com/ShadowsocksR-Live/shadowsocksr-native/archive/
$(PKG)_BINARY:=$($(PKG)_DIR)/src/ssr-server
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/ssr-server
$(PKG)_CATEGORY:=Unstable
$(PKG)_EXTRA_CFLAGS += --function-section -fdata-sections
$(PKG)_EXTRA_LDFLAGS += -Wl,--gc-sections


$(PKG)_CONFIGURE_OPTIONS += --enable-shared --disable-documentation 

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$(PKG)-cmake: $(SHADOWSOCKSR_DIR)/.unpacked
	$(SED) -i "s|add_subdirectory(depends|#add_subdirectory(depends|g" $(SHADOWSOCKSR_DIR)/CMakeLists.txt
	$(MAKE_ENV) cd $(SHADOWSOCKSR_DIR) && $(MAKE_ENV) cmake \
		-DCMAKE_C_COMPILER="$(TARGET_CC)"  \
		-DCMAKE_CXX_COMPILER="$(TARGET_CXX)"  \
		-DCMAKE_PREFIX_PATH="/home/pi/freetz-5491-7490/toolchain/build/mips_gcc-5.5.0_uClibc-1.0.14-nptl_kernel-3.10/mips-linux-uclibc" \
		-DCMAKE_VERBOSE_MAKEFILE:BOOL=ON

$($(PKG)_BINARY): $($(PKG)_DIR)/.unpacked $(PKG)-cmake
		$(SUBMAKE) -C $(SHADOWSOCKSR_DIR) \ 
        	CFLAGS="$(TARGET_CFLAGS) $(SHADOWSOCKSR_EXTRA_CFLAGS)" \
                LDFLAGS="$(TARET_LDFLAGS) $(SHADOWSOCKSR_EXTRA_LDFLAGS)" \
		VERBOSE=1

#$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
#	$(SUBMAKE) -C $(SHADOWSOCKSR_DIR) \
#		CC="$(TARGET_CC)" \
#	        CFLAGS="$(TARGET_CFLAGS) "\
#		EXTRA_CFLAGS="$(SHADOWSOCKSR_EXTRA_CFLAGS)" \
#		EXTRA_LDFLAGS="$(SHADOWSOCKSR_EXTRA_LDFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SHADOWSOCKS_DIR) clean
	$(RM) $(EMPTY_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(SHADOWSOCKS_TARGET_BINARY) 

$(PKG_FINISH)
