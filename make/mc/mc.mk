$(call PKG_INIT_BIN, 4.5.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.ibiblio.org/pub/Linux/utils/file/managers/mc/old
$(PKG)_DIR:=$(SOURCE_DIR)/$(pkg)-$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)
$(PKG)_HELP:=$($(PKG)_DIR)/src/$(pkg).hlp
$(PKG)_PKG_VERSION:=0.5b
$(PKG)_PKG_SOURCE:=$(pkg)-$($(PKG)_VERSION)-dsmod-$($(PKG)_PKG_VERSION).tar.bz2
$(PKG)_PKG_SITE:=http://dsmod.magenbrot.net
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg).bin
$(PKG)_TARGET_HELP:=$($(PKG)_DEST_DIR)/usr/lib/mc/$(pkg).hlp

$(PKG)_DS_CONFIG_FILE:=$($(PKG)_MAKE_DIR)/.ds_config
$(PKG)_DS_CONFIG_TEMP:=$($(PKG)_MAKE_DIR)/.ds_config.temp

$(PKG_SOURCE_DOWNLOAD)

# These two are not flexible enough yet for packages with sub-options, because
# we have more prerequisites for targets on one hand and special conditions
# within actions on the other hand.
#$(PKG_UNPACKED)
#$(PKG_CONFIGURED_CONFIGURE)

$(DL_DIR)/$($(PKG)_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(MC_PKG_SOURCE) $(MC_PKG_SITE)

# Exclude online help setting (DS_MC_ONLINE_HELP) from config file, because we
# do not want a full rebuild if only one help file must be copied or removed.
#@echo "DS_MC_ONLINE_HELP=$(if $(DS_MC_ONLINE_HELP),y,n)" >> $(MC_DS_CONFIG_TEMP)
$($(PKG)_DS_CONFIG_FILE): $(TOPDIR)/.config
	@echo "DS_MC_INTERNAL_EDITOR=$(if $(DS_MC_INTERNAL_EDITOR),y,n)" > $(MC_DS_CONFIG_TEMP)
	@echo "DS_MC_SYNTAX_COLOURING=$(if $(DS_MC_SYNTAX_COLOURING),y,n)" >> $(MC_DS_CONFIG_TEMP)
	@diff -q $(MC_DS_CONFIG_TEMP) $(MC_DS_CONFIG_FILE) || \
		cp $(MC_DS_CONFIG_TEMP) $(MC_DS_CONFIG_FILE)
	@rm -f $(MC_DS_CONFIG_TEMP)

# Make sure that a perfectly clean build is performed whenever DS-Mod package
# options have changed. The safest way to achieve this is by starting over
# with the source directory.
$($(PKG)_DIR)/.unpacked: $(DL_DIR)/$($(PKG)_SOURCE) $($(PKG)_DS_CONFIG_FILE)
	rm -rf $(MC_DIR)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(MC_SOURCE)
	for i in $(MC_MAKE_DIR)/patches/*.patch; do \
		$(PATCH_TOOL) $(MC_DIR) $$i; \
	done
ifneq ($(strip $(DS_$(PKG)_SYNTAX_COLOURING)),y)
	$(PATCH_TOOL) $(MC_DIR) $(MC_MAKE_DIR)/patches/cond/mc-no-syntax-colouring.patch
endif
	touch $@

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked
	( cd $(MC_DIR); rm -f config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="" \
		ac_cv_lib_intl_tolower=no \
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
		--without-x \
		--without-subshell \
		--with-terminfo \
		--without-gpm-mouse \
		--with-included-slang \
		$(if $(DS_MC_INTERNAL_EDITOR),,--without-edit) \
	);
	touch $@

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" $(MAKE) -C $(MC_DIR)

$($(PKG)_HELP): $(MC_DIR)/.unpacked

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_HELP): $($(PKG)_HELP)
	cp $(MC_HELP) $(MC_TARGET_HELP)

$(PACKAGES_DIR)/.$(pkg)-$($(PKG)_VERSION): $(DL_DIR)/$($(PKG)_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(MC_PKG_SOURCE)
	@touch $@

$(pkg): $(PACKAGES_DIR)/.$(pkg)-$($(PKG)_VERSION)

$(pkg)-package: $(PACKAGES_DIR)/.$(pkg)-$($(PKG)_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(MC_PKG_SOURCE) mc-$(MC_VERSION)

ifeq ($(strip $(DS_$(PKG)_ONLINE_HELP)),y)
$(pkg)-precompiled: uclibc ncurses $(pkg) $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_HELP)
else
$(pkg)-precompiled: uclibc ncurses $(pkg) $($(PKG)_TARGET_BINARY) $(pkg)-clean-help
endif

$(pkg)-source: $($(PKG)_DIR)/.unpacked $(PACKAGES_DIR)/.$(pkg)-$($(PKG)_VERSION)

$(pkg)-clean-help: 
	@rm -f $(MC_TARGET_HELP)

$(pkg)-clean:
	-$(MAKE) -C $(MC_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(MC_PKG_SOURCE)

$(pkg)-uninstall: 
	rm -f $(MC_TARGET_BINARY)
	rm -f $(MC_TARGET_HELP)

$(PKG_FINISH)
