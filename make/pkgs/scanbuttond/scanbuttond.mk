$(call PKG_INIT_BIN, 0.2.3.cvs20090713.orig)
$(PKG)_LIB_VERSION:=1.0.0
$(PKG)_SOURCE:=$(pkg)_$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://ftp.de.debian.org/debian/pool/main/s/scanbuttond
$(PKG)_HASH:=1cf06323b76bdb263dc1eed98460d0a33ca92a27a48d8dfd3ed56bda2b3654c5

$(PKG)_INSTALL_SUBDIR:=_install

$(PKG)_BACKENDS_ALL       := artec_eplus48u epson genesys gt68xx hp3500 hp3900 hp5590 meta mustek niash plustek plustek_umax snapscan
$(PKG)_BACKENDS           := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_BACKENDS_ALL),BACKEND)

$(PKG)_BINARY_BUILD_DIR   := $($(PKG)_DIR)/$($(PKG)_INSTALL_SUBDIR)/usr/bin/scanbuttond
$(PKG)_BINARY_TARGET_DIR  := $($(PKG)_DEST_DIR)/usr/bin/scanbuttond

$(PKG)_LIBS               := $($(PKG)_BACKENDS:%=libscanbtnd-backend_%.so.$($(PKG)_LIB_VERSION)) libscanbtnd-interface_usb.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIBS_BUILD_DIR     := $($(PKG)_LIBS:%=$($(PKG)_DIR)/$($(PKG)_INSTALL_SUBDIR)$(FREETZ_LIBRARY_DIR)/%)
$(PKG)_LIBS_TARGET_DIR    := $($(PKG)_LIBS:%=$($(PKG)_DEST_DIR)$(FREETZ_LIBRARY_DIR)/%)

$(PKG)_SCRIPTS            := buttonpressed.sh.example initscanner.sh.example
$(PKG)_SCRIPTS_BUILD_DIR  := $($(PKG)_SCRIPTS:%=$($(PKG)_DIR)/$($(PKG)_INSTALL_SUBDIR)/mod/etc/scanbuttond/%)
$(PKG)_SCRIPTS_TARGET_DIR := $($(PKG)_SCRIPTS:%=$($(PKG)_DEST_DIR)/etc/default.scanbuttond/%)

$(PKG)_META_TARGET_DIR    := $($(PKG)_DEST_DIR)/etc/default.scanbuttond/meta.conf

$(PKG)_CATEGORY:=Unstable

$(PKG)_REBUILD_SUBOPTS += $(foreach backend,$($(PKG)_BACKENDS_ALL),FREETZ_PACKAGE_SCANBUTTOND_BACKEND_$(backend))
$(PKG)_REBUILD_SUBOPTS += $(LIBUSB_REBUILD_SUBOPTS)

$(PKG)_DEPENDS_ON += libusb

$(PKG)_CONFIGURE_PRE_CMDS += $(AUTORECONF)
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --libdir=$(FREETZ_LIBRARY_DIR)
$(PKG)_CONFIGURE_OPTIONS += --libexecdir=$(FREETZ_LIBRARY_DIR)
$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/mod/etc

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_DIR)/.compiled: $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SCANBUTTOND_DIR)
	@touch $@

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.compiled
	mkdir -p $(SCANBUTTOND_DIR)/$(SCANBUTTOND_INSTALL_SUBDIR) && \
	$(SUBMAKE) -C $(SCANBUTTOND_DIR) \
		DESTDIR="$(abspath $(SCANBUTTOND_DIR)/$(SCANBUTTOND_INSTALL_SUBDIR))" \
		install && \
	touch $@

$($(PKG)_BINARY_BUILD_DIR) $($(PKG)_LIBS_BUILD_DIR) $($(PKG)_SCRIPTS_BUILD_DIR): $($(PKG)_DIR)/.installed

$($(PKG)_BINARY_TARGET_DIR): $($(PKG)_BINARY_BUILD_DIR)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_DEST_DIR)$(FREETZ_LIBRARY_DIR)/%: $($(PKG)_DIR)/$($(PKG)_INSTALL_SUBDIR)$(FREETZ_LIBRARY_DIR)/%
	$(INSTALL_LIBRARY_STRIP)

$($(PKG)_SCRIPTS_TARGET_DIR): $($(PKG)_DEST_DIR)/etc/default.scanbuttond/%: $($(PKG)_DIR)/$($(PKG)_INSTALL_SUBDIR)/mod/etc/scanbuttond/%
	$(INSTALL_FILE)

$($(PKG)_META_TARGET_DIR): $($(PKG)_DIR)/.unpacked
	mkdir -p "$(dir $@)" && \
	echo -n > "$@" && \
	for backend in $(SCANBUTTOND_BACKENDS); do \
		echo libscanbtnd-backend_$$backend >> "$@"; \
	done

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARY_TARGET_DIR) $($(PKG)_LIBS_TARGET_DIR) $($(PKG)_SCRIPTS_TARGET_DIR) $($(PKG)_META_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SCANBUTTOND_DIR) clean
	$(RM) $(SCANBUTTOND_DIR)/{.configured,.compiled,.installed}

$(pkg)-uninstall:
	$(RM) -r \
		$(SCANBUTTOND_BINARY_TARGET_DIR) \
		$(SCANBUTTOND_DEST_DIR)$(FREETZ_LIBRARY_DIR)/libscanbtnd* \
		$(SCANBUTTOND_SCRIPTS_TARGET_DIR) \
		$(SCANBUTTOND_META_TARGET_DIR)

$(PKG_FINISH)
