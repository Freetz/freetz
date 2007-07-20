RRDTOOL_VERSION:=1.2.23
RRDTOOL_SOURCE:=rrdtool-$(RRDTOOL_VERSION).tar.gz
RRDTOOL_SITE:=http://oss.oetiker.ch/rrdtool/pub/
RRDTOOL_MAKE_DIR:=$(MAKE_DIR)/rrdtool
RRDTOOL_DIR:=$(SOURCE_DIR)/rrdtool-$(RRDTOOL_VERSION)
RRDTOOL_BINARY:=$(RRDTOOL_DIR)/src/rrdtool
RRDTOOL_PKG_VERSION:=0.1
RRDTOOL_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages
RRDTOOL_PKG_NAME:=rrdtool-$(RRDTOOL_VERSION)
RRDTOOL_PKG_SOURCE:=rrdtool-$(RRDTOOL_VERSION)-dsmod-$(RRDTOOL_PKG_VERSION).tar.bz2
RRDTOOL_TARGET_DIR:=$(PACKAGES_DIR)/rrdtool-$(RRDTOOL_VERSION)
RRDTOOL_TARGET_BINARY:=$(RRDTOOL_TARGET_DIR)/root/usr/bin/rrdtool

$(DL_DIR)/$(RRDTOOL_SOURCE):
	wget -P $(DL_DIR) $(RRDTOOL_SITE)/$(RRDTOOL_SOURCE)

$(DL_DIR)/$(RRDTOOL_PKG_SOURCE):
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(RRDTOOL_PKG_SOURCE) $(RRDTOOL_PKG_SITE)

$(RRDTOOL_DIR)/.unpacked: $(DL_DIR)/$(RRDTOOL_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(RRDTOOL_SOURCE)
#	for i in $(RRDTOOL_MAKE_DIR)/patches/*.patch; do \
#		patch -d $(RRDTOOL_DIR) -p0 < $$i; \
#	done
	touch $@


$(RRDTOOL_DIR)/.configured: $(RRDTOOL_DIR)/.unpacked
	( cd $(RRDTOOL_DIR); rm -f config.status; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include \
			-I$(TARGET_MAKE_PATH)/../usr/include/freetype2 \
			-I$(TARGET_MAKE_PATH)/../usr/include/libart-2.0" \
		LDFLAGS="-L$(TARGET_MAKE_PATH)/../usr/lib" \
		PKG_CONFIG_PATH="$(TARGET_MAKE_PATH)/../usr/lib/pkgconfig)" \
		ac_cv_func_setpgrp_void=yes \
		rd_cv_ieee_works=yes \
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
		  --enable-static \
		  --disable-python \
		  --disable-perl \
		  --disable-tcl \
		  --disable-ruby \
	);
	touch $@

$(RRDTOOL_BINARY): $(RRDTOOL_DIR)/.configured
	PATH="$(TARGET_PATH)" $(MAKE) -C $(RRDTOOL_DIR)

$(RRDTOOL_TARGET_BINARY): $(RRDTOOL_BINARY)
	$(INSTALL_BINARY_STRIP)

$(PACKAGES_DIR)/.$(RRDTOOL_PKG_NAME): $(DL_DIR)/$(RRDTOOL_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(RRDTOOL_PKG_SOURCE)
	@touch $@

rrdtool: $(PACKAGES_DIR)/.$(RRDTOOL_PKG_NAME)

rrdtool-package: $(PACKAGES_DIR)/.$(RRDTOOL_PKG_NAME)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(RRDTOOL_PKG_SOURCE) $(RRDTOOL_PKG_NAME)

rrdtool-precompiled: uclibc libpng-precompiled freetype-precompiled libart-precompiled \
			rrdtool $(RRDTOOL_TARGET_BINARY)

rrdtool-source: $(RRDTOOL_DIR)/.unpacked $(PACKAGES_DIR)/.$(RRDTOOL_PKG_NAME)

rrdtool-clean:
	-$(MAKE) -C $(RRDTOOL_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(RRDTOOL_PKG_SOURCE)

rrdtool-dirclean:
	rm -rf $(RRDTOOL_DIR)
	rm -rf $(PACKAGES_DIR)/$(RRDTOOL_PKG_NAME)
	rm -f $(PACKAGES_DIR)/.$(RRDTOOL_PKG_NAME)

rrdtool-uninstall:
	rm -f $(RRDTOOL_TARGET_BINARY)

rrdtool-list:
ifeq ($(strip $(DS_PACKAGE_RRDTOOL)),y)
	@echo "S40rrdtool-$(RRDTOOL_VERSION)" >> .static
else
	@echo "S40rrdtool-$(RRDTOOL_VERSION)" >> .dynamic
endif
