$(call PKG_INIT_BIN, 3.0.STABLE26)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=3e54ae3ad09870203862f0856c7d0cca16a85f62d5012085009003ee3d5467b4
$(PKG)_SITE:=http://www.squid-cache.org/Versions/v3/$(call GET_MAJOR_VERSION,$($(PKG)_VERSION))

$(PKG)_BINARY:=$($(PKG)_DIR)/src/squid
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/squid
$(PKG)_CATEGORY:=Unstable

$(PKG)_DEPENDS_ON += $(STDCXXLIB)
$(PKG)_REBUILD_SUBOPTS += FREETZ_STDCXXLIB

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SQUID_TRANSPARENT

$(PKG)_CONFIGURE_ENV += ac_cv_func_setresuid=yes
$(PKG)_CONFIGURE_ENV += ac_cv_func_setresuid=yes
$(PKG)_CONFIGURE_ENV += ac_cv_func_strnstr=no
$(PKG)_CONFIGURE_ENV += ac_cv_func_va_copy=yes
$(PKG)_CONFIGURE_ENV += ac_cv_func___va_copy=yes
$(PKG)_CONFIGURE_ENV += ac_cv_test_checkforhugeobjects=no

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_SQUID_TRANSPARENT),--enable-linux-netfilter,--disable-linux-netfilter)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SQUID_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SQUID_DIR) clean
	$(RM) $(SQUID_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(SQUID_TARGET_BINARY)

$(PKG_FINISH)
