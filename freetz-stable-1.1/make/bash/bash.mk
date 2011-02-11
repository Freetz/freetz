$(call PKG_INIT_BIN, 3.2.48)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=ftp://ftp.gnu.org/gnu/bash
$(PKG)_BINARY:=$(BASH_DIR)/bash
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/bin/bash

ifeq ($(strip $(FREETZ_PACKAGE_BASH_READLINE)),y)
$(PKG)_DEPENDS_ON := ncurses readline
endif

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_BASH_MINIMAL
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_BASH_READLINE

$(PKG)_CONFIGURE_ENV += ac_cv_func_setvbuf_reversed=no
$(PKG)_CONFIGURE_ENV += bash_cv_have_mbstate_t=yes
$(PKG)_CONFIGURE_ENV += bash_cv_ulimit_maxfds=yes
$(PKG)_CONFIGURE_ENV += bash_cv_func_sigsetjmp=present
$(PKG)_CONFIGURE_ENV += bash_cv_printf_a_format=yes
$(PKG)_CONFIGURE_ENV += bash_cv_job_control_missing=present
$(PKG)_CONFIGURE_ENV += bash_cv_sys_named_pipes=present
$(PKG)_CONFIGURE_ENV += bash_cv_unusable_rtsigs=no
$(PKG)_CONFIGURE_ENV += bash_cv_sys_siglist=yes
$(PKG)_CONFIGURE_ENV += bash_cv_under_sys_siglist=yes
$(PKG)_CONFIGURE_ENV += ac_cv_rl_version=5.2
$(PKG)_CONFIGURE_ENV += LOCAL_LIBS="-lm"

$(PKG)_CONFIGURE_OPTIONS += --disable-restricted
$(PKG)_CONFIGURE_OPTIONS += --without-bash-malloc
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_BASH_MINIMAL),--enable-minimal-config,)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_BASH_READLINE),,--disable-readline)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_BASH_READLINE),,--disable-history)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_BASH_READLINE),,--disable-bang-history)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_BASH_READLINE),--with-installed-readline,)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(BASH_DIR)/builtins \
		LDFLAGS_FOR_BUILD= mkbuiltins
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(BASH_DIR) \
		READLINE_LDFLAGS="" \
		HISTORY_LDFLAGS="" \
		all

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(BASH_DIR) clean

$(pkg)-uninstall:
	$(RM) $(BASH_TARGET_BINARY)

$(PKG_FINISH)
