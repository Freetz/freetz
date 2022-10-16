$(call PKG_INIT_BIN,7.6)
$(PKG)_LIB_VERSION:=0.7.6
$(PKG)_SOURCE:=$(pkg)_$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=9543d7adedf78a6de0b221ccbbd1952e08b5138717f4ade814039bb489a4315d
$(PKG)_SITE:=ftp://ftp.porcupine.org/pub/security

$(PKG)_BINARY:=$($(PKG)_DIR)/tcpd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/sbin/tcpd
$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/shared/libwrap.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libwrap.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_DEST_LIBDIR)/libwrap.so.$($(PKG)_LIB_VERSION)

$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY) $($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured
	for target in config-check all; do \
	$(SUBMAKE) -C $(TCP_WRAPPERS_DIR) \
		CC="$(TARGET_CC)" \
		COPTS="$(TARGET_CFLAGS)" \
		EXTRA_CFLAGS="-DSYS_ERRLIST_DEFINED -DHAVE_STRERROR -DHAVE_WEAKSYMS -D_REENTRANT -DINET6=$(if $(FREETZ_TARGET_IPV6_SUPPORT),1,0) -Dss_family=__ss_family -Dss_len=__ss_len" \
		RANLIB="$(TARGET_RANLIB)" \
		AR="$(TARGET_AR)" \
		ARFLAGS=rv \
		AUX_OBJ=weak_symbols.o \
		LIBS="" \
		NETGROUP= \
		TLI= \
		VSYSLOG= \
		BUGS= \
		FACILITY=LOG_DAEMON \
		SEVERITY=LOG_INFO \
		REAL_DAEMON_DIR=/usr/sbin \
		STYLE="-DPROCESS_OPTIONS" \
		$$target; \
	done

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	chmod 644 $(TCP_WRAPPERS_DIR)/tcpd.h
	cp $(TCP_WRAPPERS_DIR)/tcpd.h $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include
	cp $(TCP_WRAPPERS_DIR)/libwrap.a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib
	cp -a $(TCP_WRAPPERS_DIR)/shared/libwrap*.so* $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_LIB_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(TCP_WRAPPERS_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/tcpd.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libwrap.a \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libwrap*.so*

$(pkg)-uninstall:
	$(RM) \
		$(TCP_WRAPPERS_TARGET_BINARY) \
		$(TCP_WRAPPERS_DEST_LIBDIR)/libwrap*.so*

$(PKG_FINISH)
