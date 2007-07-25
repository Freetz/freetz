# released under the GNU public license v2
#
TOR_VERSION:=0.1.2.15
TOR_SOURCE:=tor-$(TOR_VERSION).tar.gz
TOR_SITE:=http://tor.eff.org/dist
TOR_MAKE_DIR:=$(MAKE_DIR)/tor
TOR_DIR:=$(SOURCE_DIR)/tor-$(TOR_VERSION)
TOR_BINARY:=$(TOR_DIR)/src/or/tor
TOR_PKG_VERSION:=0.6
TOR_PKG_SITE:=http://netfreaks.org/ds-mod
TOR_PKG_NAME:=tor-$(TOR_VERSION)
TOR_PKG_SOURCE:=tor-$(TOR_VERSION)-dsmod-$(TOR_PKG_VERSION).tar.bz2
TOR_TARGET_DIR:=$(PACKAGES_DIR)/$(TOR_PKG_NAME)
TOR_TARGET_BINARY:=$(TOR_TARGET_DIR)/root/usr/sbin/tor

$(DL_DIR)/$(TOR_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(TOR_SITE)/$(TOR_SOURCE)

$(DL_DIR)/$(TOR_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(TOR_PKG_SOURCE) $(TOR_PKG_SITE)

$(TOR_DIR)/.unpacked: $(DL_DIR)/$(TOR_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(TOR_SOURCE)
	#for i in $(TOR_MAKE_DIR)/patches/*.patch; do \
	#	patch -d $(TOR_DIR) -p1 < $$i; \
	#done
	touch $@

$(TOR_DIR)/.configured: $(TOR_DIR)/.unpacked 
	( cd $(TOR_DIR); rm -f config.status; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-L$(TARGET_MAKE_PATH)/../usr/lib" \
		CROSS_COMPILE="yes" \
		ac_cv_libevent_linker_option='(none)' \
		ac_cv_openssl_linker_option='(none)' \
		ac_cv_libevent_normal=yes \
		tor_cv_null_is_zero=yes \
		tor_cv_unaligned_ok=yes \
		tor_cv_time_t_signed=yes \
		./configure \
		  --target=$(GNU_TARGET_NAME) \
		  --host=$(GNU_TARGET_NAME) \
		  --build=$(GNU_HOST_NAME) \
		  --program-prefix="" \
		  --program-suffix="" \
		  --prefix=/usr \
		  --exec-prefix=/usr \
		  --bindir=/usr/sbin \
		  --datadir=/usr/share \
		  --includedir=/usr/include \
		  --infodir=/usr/share/info \
		  --libdir=/usr/lib \
		  --libexecdir=/usr/lib \
		  --localstatedir=/var \
		  --mandir=/usr/share/man \
		  --sbindir=/usr/sbin \
		  --sysconfdir=/mod/etc \
		  $(DISABLE_LARGEFILE) \
		  $(DISABLE_NLS) \
		  --enable-shared \
		  --disable-static \
		  --with-gnu-ld \
		  --with-ssl-dir="$(TARGET_MAKE_PATH)/../usr/lib" \
		  --with-libevent-dir="$(TARGET_MAKE_PATH)/../usr/lib" \
	);
	touch $@

$(TOR_BINARY): $(TOR_DIR)/.configured
	PATH="$(TARGET_PATH)" \
	$(MAKE) CFLAGS="$(TARGET_CFLAGS)" -C $(TOR_DIR)
	
$(TOR_TARGET_BINARY): $(TOR_BINARY)
	$(INSTALL_BINARY_STRIP)

$(PACKAGES_DIR)/.$(TOR_PKG_NAME): $(DL_DIR)/$(TOR_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(TOR_PKG_SOURCE)
	@touch $@

tor: $(PACKAGES_DIR)/.$(TOR_PKG_NAME)

tor-package: $(PACKAGES_DIR)/.$(TOR_PKG_NAME)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(TOR_PKG_SOURCE) $(TOR_PKG_NAME)

tor-precompiled: uclibc openssl-precompiled libevent-precompiled tor $(TOR_TARGET_BINARY)

tor-source: $(TOR_DIR)/.unpacked $(PACKAGES_DIR)/.$(TOR_PKG_NAME)

tor-clean:
	-$(MAKE) -C $(TOR_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(TOR_PKG_SOURCE)

tor-dirclean:
	rm -rf $(TOR_DIR)
	rm -rf $(PACKAGES_DIR)/$(TOR_PKG_NAME)
	rm -f $(PACKAGES_DIR)/.$(TOR_PKG_NAME)
	
tor-uninstall:
	rm -f $(TOR_TARGET_BINARY)


tor-list:
ifeq ($(strip $(DS_PACKAGE_TOR)),y)
	@echo "S40tor-$(TOR_VERSION)" >> .static
else
	@echo "S40tor-$(TOR_VERSION)" >> .dynamic
endif
