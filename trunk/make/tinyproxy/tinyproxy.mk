TINYPROXY_VERSION:=1.7.0
TINYPROXY_SOURCE:=tinyproxy-$(TINYPROXY_VERSION).tar.gz
TINYPROXY_SITE:=http://mesh.dl.sourceforge.net/sourceforge/tinyproxy
TINYPROXY_MAKE_DIR:=$(MAKE_DIR)/tinyproxy
TINYPROXY_DIR:=$(SOURCE_DIR)/tinyproxy-$(TINYPROXY_VERSION)
TINYPROXY_BINARY:=$(TINYPROXY_DIR)/src/tinyproxy
TINYPROXY_PKG_VERSION:=0.1
TINYPROXY_PKG_SITE:=http://netfreaks.org/ds-mod
TINYPROXY_PKG_NAME:=tinyproxy-$(TINYPROXY_VERSION)
TINYPROXY_PKG_SOURCE:=tinyproxy-$(TINYPROXY_VERSION)-dsmod-$(TINYPROXY_PKG_VERSION).tar.bz2
TINYPROXY_TARGET_DIR:=$(PACKAGES_DIR)/$(TINYPROXY_PKG_NAME)
TINYPROXY_TARGET_BINARY:=$(TINYPROXY_TARGET_DIR)/root/usr/sbin/tinyproxy

TINYPROXY_DS_CONFIG_FILE:=$(TINYPROXY_MAKE_DIR)/.ds_config
TINYPROXY_DS_CONFIG_TEMP:=$(TINYPROXY_MAKE_DIR)/.ds_config.temp

$(DL_DIR)/$(TINYPROXY_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(TINYPROXY_SITE)/$(TINYPROXY_SOURCE)

$(DL_DIR)/$(TINYPROXY_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(TINYPROXY_PKG_SOURCE) $(TINYPROXY_PKG_SITE)

$(TINYPROXY_DS_CONFIG_FILE): $(TOPDIR)/.config
	@echo "DS_COMPILE_TINYPROXY_WITH_TRANSPARENT_PROXY=$(if $(DS_COMPILE_TINYPROXY_WITH_TRANSPARENT_PROXY),y,n)" > $(TINYPROXY_DS_CONFIG_TEMP)
	@echo "DS_COMPILE_TINYPROXY_WITH_UPSTREAM=$(if $(DS_COMPILE_TINYPROXY_WITH_UPSTREAM),y,n)" >> $(TINYPROXY_DS_CONFIG_TEMP)
	@echo "DS_COMPILE_TINYPROXY_WITH_FILTER=$(if $(DS_COMPILE_TINYPROXY_WITH_FILTER),y,n)" >> $(TINYPROXY_DS_CONFIG_TEMP)
	@echo "DS_COMPILE_TINYPROXY_WITH_SOCKS=$(if $(DS_COMPILE_TINYPROXY_WITH_SOCKS),y,n)" >> $(TINYPROXY_DS_CONFIG_TEMP)
	@diff -q $(TINYPROXY_DS_CONFIG_TEMP) $(TINYPROXY_DS_CONFIG_FILE) || \
		cp $(TINYPROXY_DS_CONFIG_TEMP) $(TINYPROXY_DS_CONFIG_FILE)
	@rm -f $(TINYPROXY_DS_CONFIG_TEMP)

# Make sure that a perfectly clean build is performed whenever DS-Mod package
# options have changed. The safest way to achieve this is by starting over
# with the source directory.
$(TINYPROXY_DIR)/.unpacked: $(DL_DIR)/$(TINYPROXY_SOURCE) $(TINYPROXY_DS_CONFIG_FILE)
	rm -rf $(TINYPROXY_DIR)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(TINYPROXY_SOURCE)
#	for i in $(TINYPROXY_MAKE_DIR)/patches/*.patch; do \
#		patch -d $(TINYPROXY_DIR) -p0 < $$i; \
#	done
	touch $@

$(TINYPROXY_DIR)/.configured: $(TINYPROXY_DIR)/.unpacked
	( cd $(TINYPROXY_DIR); rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-L$(TARGET_MAKE_PATH)/../usr/lib" \
		tinyproxy_cv_regex_broken=no \
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
		--localstatedir=/var \
		--mandir=/usr/share/man \
		--sbindir=/usr/sbin \
		--sysconfdir=/etc \
		$(DISABLE_NLS) \
		$(DISABLE_LARGEFILE) \
		--disable-static \
		$(if $(DS_COMPILE_TINYPROXY_WITH_TRANSPARENT_PROXY),--enable-transparent-proxy) \
		$(if $(DS_COMPILE_TINYPROXY_WITH_UPSTREAM),,--disable-upstream) \
		$(if $(DS_COMPILE_TINYPROXY_WITH_FILTER),,--disable-filter) \
		$(if $(DS_COMPILE_TINYPROXY_WITH_SOCKS),--enable-socks) \
	);
	touch $@

$(TINYPROXY_BINARY): $(TINYPROXY_DIR)/.configured
	PATH="$(TARGET_PATH)" \
	$(MAKE) CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		CFLAGS="-DNDEBUG $(TARGET_CFLAGS)" \
		LDFLAGS="-L$(TARGET_MAKE_PATH)/../usr/lib" \
		-C $(TINYPROXY_DIR) 

$(TINYPROXY_TARGET_BINARY): $(TINYPROXY_BINARY)
	$(INSTALL_BINARY_STRIP)

$(PACKAGES_DIR)/.$(TINYPROXY_PKG_NAME): $(DL_DIR)/$(TINYPROXY_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(TINYPROXY_PKG_SOURCE)
	@touch $@

tinyproxy: $(PACKAGES_DIR)/.$(TINYPROXY_PKG_NAME)

tinyproxy-package: $(PACKAGES_DIR)/.$(TINYPROXY_PKG_NAME)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(TINYPROXY_PKG_SOURCE) $(TINYPROXY_PKG_NAME) 

tinyproxy-precompiled: uclibc tinyproxy $(TINYPROXY_TARGET_BINARY)

tinyproxy-source: $(TINYPROXY_DIR)/.unpacked $(PACKAGES_DIR)/.$(TINYPROXY_PKG_NAME)

tinyproxy-clean:
	-$(MAKE) -C $(TINYPROXY_DIR) clean
	rm -f $(TINYPROXY_DIR)/$(TINYPROXY_TARGET_BINARY)
	rm -f $(PACKAGES_BUILD_DIR)/$(TINYPROXY_PKG_SOURCE)
	rm -f $(TINYPROXY_DS_CONFIG_FILE)

tinyproxy-dirclean:
	rm -rf $(TINYPROXY_DIR)
	rm -rf $(PACKAGES_DIR)/$(TINYPROXY_PKG_NAME)
	rm -f $(PACKAGES_DIR)/.$(TINYPROXY_PKG_NAME)
	rm -f $(TINYPROXY_DS_CONFIG_FILE)

tinyproxy-uninstall:
	rm -f $(TINYPROXY_TARGET_BINARY)

tinyproxy-list:
ifeq ($(strip $(DS_PACKAGE_TINYPROXY)),y)
	@echo "S40tinyproxy-$(TINYPROXY_VERSION)" >> .static
else
	@echo "S40tinyproxy-$(TINYPROXY_VERSION)" >> .dynamic
endif
