# released under the GNU public license v2
#
PRIVOXY_VERSION:=3.0.6
PRIVOXY_SOURCE:=privoxy-$(PRIVOXY_VERSION)-stable-src.tar.gz
PRIVOXY_SITE:=http://surfnet.dl.sourceforge.net/sourceforge/ijbswa
PRIVOXY_MAKE_DIR:=$(MAKE_DIR)/privoxy
PRIVOXY_DIR:=$(SOURCE_DIR)/privoxy-$(PRIVOXY_VERSION)-stable
PRIVOXY_BINARY:=$(PRIVOXY_DIR)/privoxy
PRIVOXY_PKG_VERSION:=0.4
PRIVOXY_PKG_SITE:=http://netfreaks.org/ds-mod
PRIVOXY_PKG_NAME:=privoxy-$(PRIVOXY_VERSION)
PRIVOXY_PKG_SOURCE:=privoxy-$(PRIVOXY_VERSION)-dsmod-$(PRIVOXY_PKG_VERSION).tar.bz2
PRIVOXY_TARGET_DIR:=$(PACKAGES_DIR)/$(PRIVOXY_PKG_NAME)
PRIVOXY_TARGET_BINARY:=$(PRIVOXY_TARGET_DIR)/root/usr/sbin/privoxy

$(DL_DIR)/$(PRIVOXY_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(PRIVOXY_SITE)/$(PRIVOXY_SOURCE)

$(DL_DIR)/$(PRIVOXY_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(PRIVOXY_PKG_SOURCE) $(PRIVOXY_PKG_SITE)

$(PRIVOXY_DIR)/.unpacked: $(DL_DIR)/$(PRIVOXY_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(PRIVOXY_SOURCE)
	for i in $(PRIVOXY_MAKE_DIR)/patches/*.patch; do \
		patch -d $(PRIVOXY_DIR) -p0 < $$i; \
	done
	touch $@

$(PRIVOXY_DIR)/.configured: $(PRIVOXY_DIR)/.unpacked
	( cd $(PRIVOXY_DIR); rm -f config.status; \
		autoheader; \
		autoconf; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="" \
		ac_cv_func_setpgrp_void=yes \
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
		  --with-docbook=no \
		  --disable-pthread \
		  --disable-stats \
		  --disable-dynamic-pcre \
		  --disable-dynamic-pcrs \
	);
	touch $@

$(PRIVOXY_BINARY): $(PRIVOXY_DIR)/.configured
	PATH="$(TARGET_PATH)" \
	$(MAKE) -C $(PRIVOXY_DIR)

$(PRIVOXY_TARGET_BINARY): $(PRIVOXY_BINARY)
	$(TARGET_STRIP) $(PRIVOXY_BINARY)
	cp $(PRIVOXY_BINARY) $(PRIVOXY_TARGET_BINARY)
	for s in `find $(PRIVOXY_DIR)/templates/ -type f`; do \
		d=$$(basename $$s); \
		egrep -v "^#\ " $$s | egrep -v "^#*$$" >$(PRIVOXY_TARGET_DIR)/root/etc/privoxy/templates/$$d; \
	done
	for s in $(PRIVOXY_DIR)/default.filter $(PRIVOXY_DIR)/default.action $(PRIVOXY_DIR)/standard.action \
		$(PRIVOXY_DIR)/user.action $(PRIVOXY_DIR)/user.filter; do \
		d=$$(basename $$s); \
		egrep -v "^#" $$s | egrep -v "^$$" >$(PRIVOXY_TARGET_DIR)/root/etc/privoxy/$$d; \
	done; true

$(PACKAGES_DIR)/.$(PRIVOXY_PKG_NAME): $(DL_DIR)/$(PRIVOXY_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(PRIVOXY_PKG_SOURCE)
	@touch $@

privoxy: $(PACKAGES_DIR)/.$(PRIVOXY_PKG_NAME)

privoxy-package: $(PACKAGES_DIR)/.$(PRIVOXY_PKG_NAME)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(PRIVOXY_PKG_SOURCE) $(PRIVOXY_PKG_NAME)

privoxy-precompiled: uclibc privoxy $(PRIVOXY_TARGET_BINARY)

privoxy-source: $(PRIVOXY_DIR)/.unpacked $(PACKAGES_DIR)/.$(PRIVOXY_PKG_NAME)

privoxy-clean:
	-$(MAKE) -C $(PRIVOXY_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(PRIVOXY_PKG_SOURCE)

privoxy-dirclean:
	rm -rf $(PRIVOXY_DIR)
	rm -rf $(PACKAGES_DIR)/$(PRIVOXY_PKG_NAME)
	rm -f $(PACKAGES_DIR)/.$(PRIVOXY_PKG_NAME)

privoxy-uninstall:
	rm -f $(PRIVOXY_TARGET_BINARY)

privoxy-list:
ifeq ($(strip $(DS_PACKAGE_PRIVOXY)),y)
	@echo "S40privoxy-$(PRIVOXY_VERSION)" >> .static
else
	@echo "S40privoxy-$(PRIVOXY_VERSION)" >> .dynamic
endif
