$(call PKG_INIT_BIN, 98d3ccce65)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SITE:=git@https://github.com/er13/callmonitor.git

$(PKG)_CONDITIONAL_PATCHES+=$(call qstrip,$(FREETZ_TYPE_PREFIX_SERIES_SUBDIR))

$(PKG)_STARTLEVEL=71

$(PKG)_BUILD_DIR := $($(PKG)_DIR)/build/freetz/$(pkg)-$($(PKG)_VERSION)

$(PKG)_BINARY:=$($(PKG)_BUILD_DIR)/src/recode
$(PKG)_TARGET_BINARY:=$($(PKG)_BUILD_DIR)/root/usr/lib/callmonitor/bin/recode

$(PKG)_SUBOPTS := webif actions monitor phonebook
$(PKG)_REBUILD_SUBOPTS += $(foreach subopt,$($(PKG)_SUBOPTS),FREETZ_PACKAGE_CALLMONITOR_$(subopt))
$(PKG)_FEATURES := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_SUBOPTS))

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked
	$(SUBMAKE) -C $(CALLMONITOR_DIR) \
		BUSYBOX=$(abspath $(TOOLS_DIR)/busybox) \
		VERSION=$(CALLMONITOR_VERSION) \
		collect
	@echo $(CALLMONITOR_FEATURES) > $(CALLMONITOR_BUILD_DIR)/.features
	$(SUBMAKE) -C $(CALLMONITOR_BUILD_DIR) configure
	@touch $@

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) $(TARGET_CONFIGURE_ENV) -C $(CALLMONITOR_BUILD_DIR) build

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)
	chmod 755 $@

$(pkg)-clean:
	-$(SUBMAKE) -C $(CALLMONITOR_DIR) clean

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_DIR)/.packaged

$($(PKG)_TARGET_DIR)/.packaged: $($(PKG)_DIR)/.configured $($(PKG)_TARGET_BINARY)
	$(call COPY_USING_TAR,$(CALLMONITOR_BUILD_DIR)/root,$(CALLMONITOR_DEST_DIR),--files-from=$(CALLMONITOR_BUILD_DIR)/.files)
	cp $(CALLMONITOR_BUILD_DIR)/.language $(CALLMONITOR_TARGET_DIR)/
	@touch $@

$(PKG_FINISH)
