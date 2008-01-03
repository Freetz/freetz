$(call PKG_INIT_BIN, 1.29)
$(PKG)_SOURCE:=espeak-$(ESPEAK_VERSION)-source.zip
$(PKG)_SITE:=http://kent.dl.sourceforge.net/sourceforge/espeak
$(PKG)_DIR:=$(SOURCE_DIR)/espeak-$(ESPEAK_VERSION)-source
$(PKG)_TARGET_LANGUAGE:=$(ESPEAK_DIR)/.language
$(PKG)_BINARY:=$(ESPEAK_DIR)/src/speak
$(PKG)_TARGET_BINARY:=$(ESPEAK_DEST_DIR)/usr/bin/speak

$(PKG)_DEPENDS_ON := uclibcxx

$(PKG)_DS_CONFIG_FILE:=$($(PKG)_MAKE_DIR)/.ds_config
$(PKG)_DS_CONFIG_TEMP:=$($(PKG)_MAKE_DIR)/.ds_config.temp

$(PKG_SOURCE_DOWNLOAD)

$($(PKG)_DS_CONFIG_FILE): $(TOPDIR)/.config
	@echo "DS_PACKAGE_ESPEAK_ALL_LANGUAGES=$(if $(DS_PACKAGE_ESPEAK_ALL_LANGUAGES),y,n)" > $(ESPEAK_DS_CONFIG_TEMP)
	@diff -q $(ESPEAK_DS_CONFIG_TEMP) $(ESPEAK_DS_CONFIG_FILE) || \
		cp $(ESPEAK_DS_CONFIG_TEMP) $(ESPEAK_DS_CONFIG_FILE)
	@rm -f $(ESPEAK_DS_CONFIG_TEMP)

$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $(ESPEAK_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(ESPEAK_DIR)/src \
		CXX="mipsel-linux-g++-uc" \
		CXXFLAGS="$(TARGET_CFLAGS)" \
		LIBS1="-lm"

$(ESPEAK_TARGET_BINARY): $(ESPEAK_BINARY) 
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_LANGUAGE): $(ESPEAK_DIR)/.unpacked $($(PKG)_DS_CONFIG_FILE)
	rm -r $(ESPEAK_DEST_DIR)/usr/share
	mkdir -p $(ESPEAK_DEST_DIR)/usr/share
	tar -c -C $(ESPEAK_MAKE_DIR)/files --exclude=.svn . | tar -x -C $(ESPEAK_TARGET_DIR)
	$(if $(DS_PACKAGE_ESPEAK_ALL_LANGUAGES),\
		cp -ar $(ESPEAK_DIR)/espeak-data $(ESPEAK_DEST_DIR)/usr/share/,)
	touch $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_LANGUAGE) $(ESPEAK_TARGET_BINARY) 

$(pkg)-clean:
	-$(MAKE) -C $(ESPEAK_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(ESPEAK_PKG_SOURCE)
	rm -f $(ESPEAK_DIR)/.language

$(pkg)-uninstall: 
	rm -f $(ESPEAK_TARGET_BINARY)

$(PKG_FINISH)
