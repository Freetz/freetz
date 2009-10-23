$(call PKG_INIT_BIN,7.6)
$(PKG)_LIB_VERSION:=0.7.6
$(PKG)_SOURCE:=$(pkg)_$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=ftp://ftp.porcupine.org/pub/security
$(PKG)_DIR:=$(SOURCE_DIR)/$(pkg)_$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/tcpd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/sbin/tcpd
$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/shared/libwrap.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libwrap.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/lib/libwrap.so.$($(PKG)_LIB_VERSION)
$(PKG)_SOURCE_MD5:=e6fa25f71226d090f34de3f6b122fb5a 


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY) $($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(TCP_WRAPPERS_DIR) \
		config-check
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(TCP_WRAPPERS_DIR) \
		CC="$(TARGET_CROSS)gcc" \
		OPT_CFLAGS="$(TARGET_CFLAGS)" \
		LIBS=-lnsl \
		NETGROUP= \
		VSYSLOG= \
		BUGS= \
		EXTRA_CFLAGS="-DSYS_ERRLIST_DEFINED -DHAVE_STRERROR -DHAVE_WEAKSYMS -D_REENTRANT -DINET6=0 \
			-Dss_family=__ss_family -Dss_len=__ss_len" \
		FACILITY=LOG_DAEMON \
		SEVERITY=LOG_INFO \
		REAL_DAEMON_DIR=/usr/sbin \
		STYLE="-DPROCESS_OPTIONS" \
		all

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	chmod 644 $(TCP_WRAPPERS_DIR)/tcpd.h
	cp $(TCP_WRAPPERS_DIR)/tcpd.h $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include
	cp $(TCP_WRAPPERS_DIR)/libwrap.a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib
	cp -a $(TCP_WRAPPERS_DIR)/shared/libwrap*.so* $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_STAGING_BINARY)
	mkdir -p $(dir $@)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libwrap*.so* $(TCP_WRAPPERS_TARGET_DIR)/root/usr/lib
	$(TARGET_STRIP) $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_LIB_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(TCP_WRAPPERS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/tcpd.h \
	 	$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libwrap.a \
		$(TCP_WRAPPERS_TARGET_BINARY) \
		$(TCP_WRAPPERS_LIB_TARGET_BINARY)

$(PKG_FINISH)
