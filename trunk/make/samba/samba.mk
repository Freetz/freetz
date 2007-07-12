# based on OpenWrt SVN
SAMBA_VERSION:=2.0.10
SAMBA_SOURCE:=samba-$(SAMBA_VERSION).tar.gz
SAMBA_SITE:=ftp://se.samba.org/pub/samba/stable
SAMBA_MAKE_DIR:=$(MAKE_DIR)/samba
SAMBA_DIR:=$(SOURCE_DIR)/samba-$(SAMBA_VERSION)
SAMBA_SMBD_BINARY:=$(SAMBA_DIR)/source/bin/smbd
SAMBA_NMBD_BINARY:=$(SAMBA_DIR)/source/bin/nmbd
SAMBA_TARGET_DIR:=$(PACKAGES_DIR)/samba-$(SAMBA_VERSION)
SAMBA_TARGET_SMBD_BINARY:=$(SAMBA_TARGET_DIR)/root/usr/sbin/smbd
SAMBA_TARGET_NMBD_BINARY:=$(SAMBA_TARGET_DIR)/root/usr/sbin/nmbd
SAMBA_PKG_VERSION:=0.1
SAMBA_PKG_SOURCE:=samba-$(SAMBA_VERSION)-dsmod-$(SAMBA_PKG_VERSION).tar.bz2
SAMBA_PKG_SITE:=http://dsmod.magenbrot.net


$(DL_DIR)/$(SAMBA_SOURCE): | $(DL_DIR)
	wget --passive-ftp -P $(DL_DIR) $(SAMBA_SITE)/$(SAMBA_SOURCE)

$(DL_DIR)/$(SAMBA_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(SAMBA_PKG_SOURCE) $(SAMBA_PKG_SITE)

$(SAMBA_DIR)/.unpacked: $(DL_DIR)/$(SAMBA_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(SAMBA_SOURCE)
	for i in $(SAMBA_MAKE_DIR)/patches/*.patch; do \
		patch -d $(SAMBA_DIR) -p0 < $$i; \
	done
	touch $@

$(SAMBA_DIR)/.configured: $(SAMBA_DIR)/.unpacked
	( cd $(SAMBA_DIR)/source; rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
		CFLAGS="$(TARGET_CFLAGS) -D_GNU_SOURCE -DNDEBUG -DSHMEM_SIZE=524288" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-L$(TARGET_MAKE_PATH)/../usr/lib" \
		ac_cv_lib_cups_httpConnect=no \
		ac_cv_sizeof_int=4 \
		ac_cv_sizeof_long=4 \
		ac_cv_sizeof_short=2 \
		samba_cv_FTRUNCATE_NEEDS_ROOT=no \
		samba_cv_HAVE_BROKEN_FCNTL64_LOCKS=no \
		samba_cv_HAVE_BROKEN_GETGROUPS=no \
		samba_cv_HAVE_BROKEN_READDIR=no \
		samba_cv_HAVE_FCNTL_LOCK=yes \
		samba_cv_HAVE_FNMATCH=yes \
		samba_cv_HAVE_FTRUNCATE_EXTEND=no \
		samba_cv_HAVE_GETTIMEOFDAY_TZ=yes \
		samba_cv_HAVE_IFACE_AIX=no \
		samba_cv_HAVE_IFACE_IFCONF=yes \
		samba_cv_HAVE_IFACE_IFREQ=yes \
		samba_cv_HAVE_IRIX_SPECIFIC_CAPABILITIES=no \
		samba_cv_HAVE_ROOT=yes \
		samba_cv_HAVE_SECURE_MKSTEMP=yes \
		samba_cv_HAVE_SHARED_MMAP=yes \
		samba_cv_HAVE_STRUCT_FLOCK64=yes \
		samba_cv_HAVE_SYSV_IPC=no \
		samba_cv_HAVE_TRUNCATED_SALT=no \
		samba_cv_HAVE_UNION_SEMUN=no \
		samba_cv_HAVE_UNSIGNED_CHAR=yes \
		samba_cv_NEED_SGI_SEMUN_HACK=no \
		samba_cv_REPLACE_INET_NTOA=no \
		samba_cv_SIZEOF_INO_T=4 \
		samba_cv_SIZEOF_OFF_T=4 \
		samba_cv_SYSCONF_SC_NGROUPS_MAX=yes \
		samba_cv_USE_SETEUID=yes \
		samba_cv_USE_SETRESUID=no \
		samba_cv_USE_SETREUID=yes \
		samba_cv_USE_SETUIDX=no \
		samba_cv_have_longlong=yes \
		samba_cv_have_setresgid=no \
		samba_cv_have_setresuid=no \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--program-prefix="" \
		--program-suffix="" \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--datadir=/usr/share \
		--includedir=/usr/include \
		--infodir=/usr/share/info \
		--libdir=/usr/lib \
		--libexecdir=/usr/lib \
		--localstatedir=/var/log \
		--mandir=/usr/share/man \
		--sbindir=/usr/sbin \
		--sysconfdir=/mod/etc \
		$(DISABLE_LARGEFILE) \
		$(DISABLE_NLS) \
		--with-lockdir=/var/run/samba \
		--with-privatedir=/mod/etc \
		--with-syslog \
	);
	touch $@

$(SAMBA_SMBD_BINARY) $(SAMBA_NMBD_BINARY): $(SAMBA_DIR)/.configured
	$(MAKE1) -C $(SAMBA_DIR)/source \
		$(TARGET_CONFIGURE_OPTS) \
		CC=$(TARGET_CC) \
		LD=$(TARGET_LD) \
		CODEPAGEDIR="/mod/usr/share/samba"

$(PACKAGES_DIR)/.samba-$(SAMBA_VERSION): $(DL_DIR)/$(SAMBA_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(SAMBA_PKG_SOURCE)
	@touch $@

$(SAMBA_TARGET_SMBD_BINARY): $(SAMBA_SMBD_BINARY)
	$(INSTALL_BINARY_STRIP)

$(SAMBA_TARGET_NMBD_BINARY): $(SAMBA_NMBD_BINARY)
	$(INSTALL_BINARY_STRIP)

samba: $(PACKAGES_DIR)/.samba-$(SAMBA_VERSION)

samba-package: $(PACKAGES_DIR)/.samba-$(SAMBA_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(SAMBA_PKG_SOURCE) samba-$(SAMBA_VERSION)

samba-precompiled: uclibc samba $(SAMBA_TARGET_SMBD_BINARY) $(SAMBA_TARGET_NMBD_BINARY)

samba-source: $(SAMBA_DIR)/.unpacked $(PACKAGES_DIR)/.samba-$(SAMBA_VERSION)

samba-clean:
	-$(MAKE) -C $(SAMBA_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(SAMBA_PKG_SOURCE)

samba-dirclean:
	rm -rf $(SAMBA_DIR)
	rm -rf $(PACKAGES_DIR)/samba-$(SAMBA_VERSION)
	rm -f $(PACKAGES_DIR)/.samba-$(SAMBA_VERSION)

samba-uninstall:
	rm -f $(SAMBA_TARGET_SMBD_BINARY)
	rm -f $(SAMBA_TARGET_NMBD_BINARY)

samba-list:
ifeq ($(strip $(DS_PACKAGE_SAMBA)),y)
	@echo "S40samba-$(SAMBA_VERSION)" >> .static
else
	@echo "S40samba-$(SAMBA_VERSION)" >> .dynamic
endif
