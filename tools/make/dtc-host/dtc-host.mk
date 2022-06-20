$(call TOOLS_INIT, 1.6.1)
$(PKG)_SOURCE:=dtc-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=65cec529893659a49a89740bb362f507a3b94fc8cd791e76a8d6a2b6f3203473
$(PKG)_SITE:=@KERNEL/software/utils/dtc

$(PKG)_BINARIES            := dtc fdtget fdtdump fdtput
$(PKG)_BINARIES_BUILD_DIR  := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$(TOOLS_DIR)/%)

$(PKG)_LIBFDT_BINARY:=$($(PKG)_DIR)/libfdt-freetz/libfdt.a
$(PKG)_BINARY:=$(HOST_TOOLS_DIR)/lib/libfdt.a


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.unpacked
	$(TOOLS_SUBMAKE) -C $(DTC_HOST_DIR)

$($(PKG)_BINARIES_TARGET_DIR): $(TOOLS_DIR)/%: $($(PKG)_DIR)/%
	$(INSTALL_FILE)

$($(PKG)_LIBFDT_BINARY): $($(PKG)_DIR)/.unpacked
	cp $(DTC_HOST_DIR)/libfdt/*.{c,h,libfdt} $(DTC_HOST_DIR)/libfdt-freetz/
	$(TOOLS_SUBMAKE) -f Makefile.freetz -C $(DTC_HOST_DIR)/libfdt-freetz all \
		CC="$(TOOLS_CC)" \
		BITNESS="$(HOST_CFLAGS_FORCE_32BIT_CODE)"

$($(PKG)_BINARY): $($(PKG)_LIBFDT_BINARY)
	$(TOOLS_SUBMAKE) -f Makefile.freetz -C $(DTC_HOST_DIR)/libfdt-freetz install \
		PREFIX="$(HOST_TOOLS_DIR)"

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR) $($(PKG)_BINARY)



$(pkg)-clean:
	-$(MAKE) -C $(DTC_HOST_DIR) clean
	-$(MAKE) -f Makefile.freetz -C $(DTC_HOST_DIR)/libfdt-freetz clean

$(pkg)-dirclean:
	$(RM) -r $(DTC_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(TOOLS_DIR)/dtc $(TOOLS_DIR)/fdtget $(TOOLS_DIR)/fdtdump $(TOOLS_DIR)/mkimage/fdtput
	$(RM) $(HOST_TOOLS_DIR)/lib/libfdt* $(HOST_TOOLS_DIR)/include/*fdt*.h

$(TOOLS_FINISH)
