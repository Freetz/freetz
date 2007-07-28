ESPEAK_NAME:=espeak
ESPEAK_VERSION:=1.27
ESPEAK_SOURCE:=$(ESPEAK_NAME)-$(ESPEAK_VERSION)-source.zip
ESPEAK_SITE:=http://kent.dl.sourceforge.net/sourceforge/espeak
ESPEAK_DIR:=$(SOURCE_DIR)/$(ESPEAK_NAME)-$(ESPEAK_VERSION)-source
ESPEAK_MAKE_DIR:=$(MAKE_DIR)/$(ESPEAK_NAME)
ESPEAK_BINARY:=$(ESPEAK_DIR)/src/speak
ESPEAK_TARGET_DIR:=$(PACKAGES_DIR)/$(ESPEAK_NAME)-$(ESPEAK_VERSION)
ESPEAK_TARGET_BINARY:=$(ESPEAK_TARGET_DIR)/root/usr/bin/speak
ESPEAK_PKG_VERSION:=0.1
ESPEAK_PKG_SOURCE:=$(ESPEAK_NAME)-$(ESPEAK_VERSION)-dsmod-$(ESPEAK_PKG_VERSION).tar.bz2
ESPEAK_PKG_SITE:=http://www.mhampicke.de/dsmod/packages

$(DL_DIR)/$(ESPEAK_SOURCE):
	wget -P $(DL_DIR) $(ESPEAK_SITE)/$(ESPEAK_SOURCE)

$(DL_DIR)/$(ESPEAK_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(ESPEAK_PKG_SOURCE) $(ESPEAK_PKG_SITE)

$(ESPEAK_DIR)/.unpacked: $(DL_DIR)/$(ESPEAK_SOURCE)
	unzip -o $(DL_DIR)/$(ESPEAK_SOURCE) -d $(SOURCE_DIR)
	for i in $(ESPEAK_MAKE_DIR)/patches/*.patch; do \
		$(PATCH_TOOL) $(ESPEAK_DIR) $$i 1; \
	done
	touch $@

$(ESPEAK_DIR)/.configured: $(ESPEAK_DIR)/.unpacked
	touch $@

$(ESPEAK_BINARY): $(ESPEAK_DIR)/.configured
	PATH="$(TARGET_PATH)" make -C $(ESPEAK_DIR)/src \
		CXX="mipsel-linux-g++-uc" \
		CXXFLAGS="$(TARGET_CFLAGS)" \
		LIBS1="-lm"

$(ESPEAK_TARGET_BINARY): $(ESPEAK_BINARY) 
	cp -ar $(ESPEAK_DIR)/espeak-data $(ESPEAK_TARGET_DIR)/root/usr/share/
	$(INSTALL_BINARY_STRIP)

$(PACKAGES_DIR)/.$(ESPEAK_NAME)-$(ESPEAK_VERSION): $(DL_DIR)/$(ESPEAK_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(ESPEAK_PKG_SOURCE)
	@touch $@

espeak: $(PACKAGES_DIR)/.$(ESPEAK_NAME)-$(ESPEAK_VERSION)

espeak-download: $(DL_DIR)/$(ESPEAK_SOURCE) $(DL_DIR)/$(ESPEAK_PKG_SOURCE)

espeak-package: $(PACKAGES_DIR)/.$(ESPEAK_NAME)-$(ESPEAK_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(ESPEAK_PKG_SOURCE) $(ESPEAK_NAME)-$(ESPEAK_VERSION)

espeak-precompiled: uclibc uclibcxx-precompiled espeak $(ESPEAK_TARGET_BINARY)

espeak-source: $(ESPEAK_DIR)/.unpacked $(PACKAGES_DIR)/.$(ESPEAK_NAME)-$(ESPEAK_VERSION)

espeak-clean:
	-$(MAKE) -C $(ESPEAK_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(ESPEAK_PKG_SOURCE)

espeak-dirclean:
	rm -rf $(ESPEAK_DIR)
	rm -rf $(PACKAGES_DIR)/$(ESPEAK_NAME)-$(ESPEAK_VERSION)
	rm -f $(PACKAGES_DIR)/.$(ESPEAK_NAME)-$(ESPEAK_VERSION)

espeak-uninstall: 
	rm -f $(ESPEAK_TARGET_BINARY)

espeak-list:
ifeq ($(strip $(DS_PACKAGE_ESPEAK)),y)
	@echo "S99$(ESPEAK_NAME)-$(ESPEAK_VERSION)" >> .static
else
	@echo "S99$(ESPEAK_NAME)-$(ESPEAK_VERSION)" >> .dynamic
endif
