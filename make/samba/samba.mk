$(call PKG_INIT_BIN, 3.0.37)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=11ed2bfef4090bd5736b194b43f67289
$(PKG)_SITE:=http://samba.org/samba/ftp/stable
$(PKG)_BUILD_SUBDIR:=source

$(PKG)_BINARIES_ALL := smbpasswd smbd nmbd
$(PKG)_BINARIES := $(filter-out $(if $(FREETZ_PACKAGE_NMBD),,nmbd),$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/source/bin/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/sbin/%)
$(PKG)_NOT_INCLUDED := $(patsubst %,$($(PKG)_DEST_DIR)/sbin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

$(PKG)_DEPENDS_ON+= popt

ifneq ($(FREETZ_TARGET_IPV6_SUPPORT),y)
$(PKG)_CONFIGURE_ENV += libreplace_cv_HAVE_IPV6=no
endif

# TODO:
# Set samba_cv_REALPATH_TAKES_NULL=yes when new 
# Download Toolchain is on the mirrors
$(PKG)_CONFIGURE_ENV += \
	samba_cv_HAVE_GETTIMEOFDAY_TZ=yes \
	samba_cv_USE_SETREUID=yes \
	samba_cv_HAVE_KERNEL_OPLOCKS_LINUX=yes \
	samba_cv_HAVE_IFACE_IFCONF=yes \
	samba_cv_HAVE_MMAP=yes \
	samba_cv_HAVE_FCNTL_LOCK=yes \
	samba_cv_HAVE_SECURE_MKSTEMP=yes \
	samba_cv_HAVE_NATIVE_ICONV=no \
	samba_cv_fpie=no \
	ac_cv_func_prctl=no \
	SMB_BUILD_CC_NEGATIVE_ENUM_VALUES=yes \
	samba_cv_HAVE_BROKEN_FCNTL64_LOCKS=no \
	samba_cv_HAVE_BROKEN_GETGROUPS=no \
	samba_cv_HAVE_BROKEN_READDIR_NAME=no \
	samba_cv_HAVE_C99_VSNPRINTF=yes \
	samba_cv_HAVE_DEV64_T=no \
	samba_cv_HAVE_DEVICE_MAJOR_FN=yes \
	samba_cv_HAVE_DEVICE_MINOR_FN=yes \
	samba_cv_HAVE_FTRUNCATE_EXTEND=yes \
	samba_cv_HAVE_IFACE_AIX=no \
	samba_cv_HAVE_INO64_T=no \
	samba_cv_HAVE_KERNEL_CHANGE_NOTIFY=no \
	samba_cv_HAVE_KERNEL_SHARE_MODES=yes \
	samba_cv_HAVE_MAKEDEV=yes \
	samba_cv_HAVE_OFF64_T=no \
	samba_cv_HAVE_STRUCT_FLOCK64=yes \
	samba_cv_HAVE_TRUNCATED_SALT=no \
	samba_cv_HAVE_UNSIGNED_CHAR=no \
	samba_cv_HAVE_WORKING_AF_LOCAL=yes \
	samba_cv_HAVE_Werror=yes \
	samba_cv_REALPATH_TAKES_NULL=no \
	samba_cv_REPLACE_INET_NTOA=no \
	samba_cv_SIZEOF_DEV_T=yes \
	samba_cv_SIZEOF_INO_T=yes \
	samba_cv_SIZEOF_OFF_T=yes \
	samba_cv_SIZEOF_TIME_T=no \
	samba_cv_have_setresgid=yes \
	samba_cv_have_setresuid=yes \
	samba_cv_have_longlong=yes

$(PKG)_CONFIGURE_ENV += fu_cv_sys_stat_statfs2_bsize=yes
$(PKG)_CONFIGURE_ENV += $(PKG)_fu_cv_sys_stat_statvfs=no
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_MAKE_CONF_VARIABLES_PACKAGE_SPECIFIC,fu_cv_sys_stat_statvfs)


$(PKG)_CONFIGURE_OPTIONS += --disable-swat
$(PKG)_CONFIGURE_OPTIONS += --disable-cups
$(PKG)_CONFIGURE_OPTIONS += --disable-iprint
$(PKG)_CONFIGURE_OPTIONS += --disable-pie
$(PKG)_CONFIGURE_OPTIONS += --disable-relro
$(PKG)_CONFIGURE_OPTIONS += --disable-fam
$(PKG)_CONFIGURE_OPTIONS += --disable-avahi
$(PKG)_CONFIGURE_OPTIONS += --disable-gnutls
$(PKG)_CONFIGURE_OPTIONS += --without-ldap
$(PKG)_CONFIGURE_OPTIONS += --without-ads
$(PKG)_CONFIGURE_OPTIONS += --without-cifsmount
$(PKG)_CONFIGURE_OPTIONS += --without-cifsupcall
$(PKG)_CONFIGURE_OPTIONS += --without-sys-quotas
$(PKG)_CONFIGURE_OPTIONS += --without-utmp
$(PKG)_CONFIGURE_OPTIONS += --without-cluster-support
$(PKG)_CONFIGURE_OPTIONS += --without-acl-support
$(PKG)_CONFIGURE_OPTIONS += --without-sendfile-support
$(PKG)_CONFIGURE_OPTIONS += --without-wbclient
$(PKG)_CONFIGURE_OPTIONS += --without-winbind
$(PKG)_CONFIGURE_OPTIONS += --with-krb5=no
$(PKG)_CONFIGURE_OPTIONS += --with-included-popt=no
$(PKG)_CONFIGURE_OPTIONS += --with-privatedir=/mod/etc
$(PKG)_CONFIGURE_OPTIONS += --with-configdir=/mod/etc
$(PKG)_CONFIGURE_OPTIONS += --with-piddir=/var/run
$(PKG)_CONFIGURE_OPTIONS += --with-syslog

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	for target in headers all; do \
	$(SUBMAKE) -C $(SAMBA_DIR)/source \
		RANLIB="$(TARGET_RANLIB)" \
		CODEPAGEDIR="/mod/usr/share/samba" \
		$$target; \
	done

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/sbin/%: $($(PKG)_DIR)/source/bin/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SAMBA_DIR)/source clean
	$(RM) -r $(SAMBA_DIR)/source/bin

$(pkg)-uninstall:
	$(RM) $(SAMBA_BINARIES_ALL:%=$(SAMBA_DEST_DIR)/sbin/%)

$(PKG_FINISH)
