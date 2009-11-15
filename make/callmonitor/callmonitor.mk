$(call PKG_INIT_BIN, 1.16)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION)-freetz.tar.bz2
$(PKG)_SITE:=http://download.berlios.de/callmonitor
$(PKG)_DIR:=$(SOURCE_DIR)/$(pkg)-$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/src/recode
$(PKG)_TARGET_BINARY:=$($(PKG)_DIR)/root/usr/lib/callmonitor/bin/recode
$(PKG)_STARTLEVEL=30
$(PKG)_SOURCE_MD5:=0055ab7774b871461b31334464edecd5

CALLMONITOR_FEATURES:=$(foreach feat,webif actions monitor phonebook,\
    	$(if $(FREETZ_PACKAGE_CALLMONITOR_$(feat)),$(feat)))

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)

.PHONY: FORCE

$(CALLMONITOR_DIR)/.features.new: FORCE
	@echo $(CALLMONITOR_FEATURES) > $@

$(CALLMONITOR_DIR)/.features: $(CALLMONITOR_DIR)/.features.new
	@if ! diff -q $< $@; then cp $< $@; fi

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked $($(PKG)_DIR)/.features
	$(MAKE) -C $(CALLMONITOR_DIR) configure
	@touch $@

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(MAKE) $(TARGET_CONFIGURE_ENV) -C $(CALLMONITOR_DIR) build

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)
	chmod 755 $@

$(pkg)-clean: FORCE
	if [ -d "$(CALLMONITOR_DIR)" ]; then $(MAKE) -C $(CALLMONITOR_DIR) clean; else true; fi

$(pkg) $(pkg)-precompiled: $($(PKG)_TARGET_DIR)/.packaged

$($(PKG)_TARGET_DIR)/.packaged: $(CALLMONITOR_DIR)/.configured $($(PKG)_TARGET_BINARY)
	rm -rf $(CALLMONITOR_TARGET_DIR)
	mkdir -p $(CALLMONITOR_TARGET_DIR)/root
	tar -c -C $(CALLMONITOR_DIR)/root --files-from=$(CALLMONITOR_DIR)/.files | \
	    tar -x -C $(CALLMONITOR_DEST_DIR)
	cp $(CALLMONITOR_DIR)/.language $(CALLMONITOR_TARGET_DIR)/
	@touch $@

$(PKG_FINISH)
