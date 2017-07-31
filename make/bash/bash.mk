$(call PKG_INIT_BIN, 3.2.48)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=338dcf975a93640bb3eaa843ca42e3f8
$(PKG)_SITE:=@GNU/$(pkg)

$(PKG)_BINARY:=$(BASH_DIR)/bash
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/bin/bash

ifeq ($(strip $(FREETZ_PACKAGE_BASH_READLINE)),y)
$(PKG)_DEPENDS_ON += ncurses readline
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_BASH_MINIMAL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_BASH_READLINE

$(PKG)_CONFIGURE_ENV += ac_cv_rl_prefix="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_ENV += ac_cv_rl_version=6.2
# whacky leads to DEV_FD_PREFIX "/proc/self/fd/" (instead of standard "/dev/fd/")
$(PKG)_CONFIGURE_ENV += bash_cv_dev_fd=whacky
$(PKG)_CONFIGURE_ENV += bash_cv_dup2_broken=no
$(PKG)_CONFIGURE_ENV += bash_cv_func_ctype_nonascii=no
$(PKG)_CONFIGURE_ENV += bash_cv_func_sigsetjmp=present
$(PKG)_CONFIGURE_ENV += bash_cv_func_strcoll_broken=no
$(PKG)_CONFIGURE_ENV += bash_cv_getcwd_malloc=yes
$(PKG)_CONFIGURE_ENV += bash_cv_getenv_redef=yes
$(PKG)_CONFIGURE_ENV += bash_cv_job_control_missing=present
$(PKG)_CONFIGURE_ENV += bash_cv_must_reinstall_sighandlers=no
$(PKG)_CONFIGURE_ENV += bash_cv_opendir_not_robust=no
$(PKG)_CONFIGURE_ENV += bash_cv_pgrp_pipe=no
$(PKG)_CONFIGURE_ENV += bash_cv_printf_a_format=no
$(PKG)_CONFIGURE_ENV += bash_cv_sys_named_pipes=present
$(PKG)_CONFIGURE_ENV += bash_cv_sys_siglist=no
$(PKG)_CONFIGURE_ENV += bash_cv_ulimit_maxfds=no
$(PKG)_CONFIGURE_ENV += bash_cv_under_sys_siglist=no
$(PKG)_CONFIGURE_ENV += bash_cv_unusable_rtsigs=no
$(PKG)_CONFIGURE_ENV += bash_cv_wcontinued_broken=no
# actually yes but it's safe to say no
$(PKG)_CONFIGURE_ENV += gt_cv_int_divbyzero_sigfpe=no

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
	$(SUBMAKE) -C $(BASH_DIR)/builtins \
		LDFLAGS_FOR_BUILD= mkbuiltins
	$(SUBMAKE) -C $(BASH_DIR) \
		READLINE_LDFLAGS="" \
		HISTORY_LDFLAGS="" \
		all

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(BASH_DIR) clean

$(pkg)-uninstall:
	$(RM) $(BASH_TARGET_BINARY)

$(PKG_FINISH)
