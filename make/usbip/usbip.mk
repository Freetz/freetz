$(call PKG_INIT_BIN, 182)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=4632654349aada3c4775e4d0aa844d6185ad232aef04666cf48e6bc727779751
$(PKG)_SITE:=svn://svn.code.sf.net/p/usbip/code/obsolete/linux/tags/usbip-0.1.8

$(PKG)_CATEGORY:=Unstable

$(PKG)_BINARIES            := usbipd usbip_bind_driver
$(PKG)_BINARIES_BUILD_DIR  := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/src/cmd/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/sbin/%)

# kernel 2.6.28 has stock usbip modules
$(PKG)_MODULES            := usbip.ko usbip_common_mod.ko
$(PKG)_MODULES_BUILD_DIR  := $($(PKG)_MODULES:%=$($(PKG)_DIR)/drivers/2.6.21/%)
$(PKG)_MODULES_TARGET_DIR := $($(PKG)_MODULES:%=$(KERNEL_MODULES_DIR)/drivers/usb/usbip/%)

$(PKG)_DEPENDS_ON += kernel sysfsutils glib2

$(PKG)_REBUILD_SUBOPTS += FREETZ_KERNEL_VERSION

$(PKG)_CONFIGURE_PRE_CMDS += cd src; ./autogen.sh;
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --disable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(USBIP_DIR)/src \
		CPPFLAGS="-std=gnu99 -fgnu89-inline"

$($(PKG)_MODULES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(USBIP_DIR)/drivers/2.6.21 \
		KSOURCE="$(FREETZ_BASE_DIR)/$(KERNEL_SOURCE_DIR)" \
		ARCH="$(KERNEL_ARCH)" \
		CROSS_COMPILE="$(KERNEL_CROSS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/sbin/%: $($(PKG)_DIR)/src/cmd/%
	$(INSTALL_BINARY_STRIP)

$($(PKG)_MODULES_TARGET_DIR): $(KERNEL_MODULES_DIR)/drivers/usb/usbip/%: $($(PKG)_DIR)/drivers/2.6.21/%
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR) \
	$(if $(or $(FREETZ_KERNEL_VERSION_2_6_28),$(FREETZ_KERNEL_VERSION_2_6_32)),,$($(PKG)_MODULES_TARGET_DIR))

$(pkg)-clean:
	-$(SUBMAKE) -C $(USBIP_DIR)/src clean

$(pkg)-uninstall:
	$(RM) \
		$(USBIP_BINARIES_TARGET_DIR) \
		$(if $(or $(FREETZ_KERNEL_VERSION_2_6_28),$(FREETZ_KERNEL_VERSION_2_6_32)),,$(USBIP_MODULES_TARGET_DIR))

$(PKG_FINISH)
