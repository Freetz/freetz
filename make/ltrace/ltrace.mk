$(call PKG_INIT_BIN, c22d359433)
$(PKG)_SOURCE:=ltrace-$($(PKG)_VERSION).tar.xz
$(PKG)_SITE:=git://git.debian.org/git/collab-maint/ltrace.git

$(PKG)_CATEGORY:=Debug helpers

$(PKG)_BINARY:=$($(PKG)_DIR)/ltrace
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/ltrace

$(PKG)_CONFIGS            := libacl.so.conf libc.so.conf libc.so-types.conf libm.so.conf libpthread.so.conf libpthread.so-types.conf syscalls.conf
$(PKG)_CONFIGS_BUILD_DIR  := $($(PKG)_CONFIGS:%=$($(PKG)_DIR)/etc/%)
$(PKG)_CONFIGS_TARGET_DIR := $($(PKG)_CONFIGS:%=$($(PKG)_DEST_DIR)/usr/share/ltrace/%)

$(PKG)_DEPENDS_ON += libelf

$(PKG)_CONFIGURE_PRE_CMDS += ./autogen.sh;

# disable demangling support
$(PKG)_CONFIGURE_ENV += ac_cv_lib_iberty_cplus_demangle=no
$(PKG)_CONFIGURE_ENV += ac_cv_lib_stdcpp___cxa_demangle=no
$(PKG)_CONFIGURE_ENV += ac_cv_lib_supcpp___cxa_demangle=no

$(PKG)_CONFIGURE_OPTIONS += --with-libelf="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-libunwind=no

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LTRACE_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_CONFIGS_BUILD_DIR): $($(PKG)_DIR)/etc/%: $($(PKG)_DIR)/.unpacked
	@touch $@

$($(PKG)_CONFIGS_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/share/ltrace/%: $($(PKG)_DIR)/etc/%
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_CONFIGS_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LTRACE_DIR) clean

$(pkg)-uninstall:
	$(RM) $(LTRACE_TARGET_BINARY) $(LTRACE_CONFIGS_TARGET_DIR)

$(PKG_FINISH)
