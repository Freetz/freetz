$(call PKG_INIT_BIN, 1.07)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=9d36507e0b7afdfb87533244f7d75daa1c17f2768982674f4c9add5ae6c03868
$(PKG)_SITE:=http://www.monkey.org/~marius/trickle

$(PKG)_BINARIES:=$(pkg) $(pkg)ctl $(pkg)d
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_LIBS:=$(pkg)-overload.so
$(PKG)_LIBS_BUILD_DIR:=$($(PKG)_LIBS:%=$($(PKG)_DIR)/%)
$(PKG)_LIBS_TARGET_DIR:=$($(PKG)_LIBS:%=$($(PKG)_DEST_LIBDIR)/%)

$(PKG)_DEPENDS_ON += libevent
$(PKG)_DEPENDS_ON += $(if $(FREETZ_TARGET_UCLIBC_SUPPORTS_rpc),,libtirpc)

# touch some patched files to prevent configure from being regenerated
$(PKG)_CONFIGURE_PRE_CMDS += touch -t 200001010000.00 ./configure.in ./config.h.in ./acconfig.h;
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_UCLIBC_MAJOR_VERSION
$(PKG)_CONFIGURE_ENV   += UCLIBC_MAJOR=$(FREETZ_TARGET_UCLIBC_MAJOR_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --with-libevent="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"

ifneq ($(strip $(FREETZ_TARGET_UCLIBC_SUPPORTS_rpc)),y)
$(PKG)_CFLAGS += -I$(TARGET_TOOLCHAIN_STAGING_DIR)/include/tirpc
$(PKG)_LDFLAGS += -ltirpc
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR) $($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(TRICKLE_DIR) \
		CFLAGS="$(TARGET_CFLAGS) $(TRICKLE_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS) $(TRICKLE_LDFLAGS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_DEST_LIBDIR)/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR) $($(PKG)_LIBS_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(TRICKLE_DIR) clean
	$(RM) $(TRICKLE_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(TRICKLE_BINARIES_TARGET_DIR) $(TRICKLE_LIBS_TARGET_DIR)

$(PKG_FINISH)
