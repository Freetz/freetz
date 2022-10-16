$(call TOOLS_INIT, 1.6.1)
$(PKG)_SOURCE:=dtc-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=65cec529893659a49a89740bb362f507a3b94fc8cd791e76a8d6a2b6f3203473
$(PKG)_SITE:=@KERNEL/software/utils/dtc

$(PKG)_LIBFDT_BINARY:=$($(PKG)_DIR)/libfdt/libfdt.a
$(PKG)_BINARY:=$(HOST_TOOLS_DIR)/lib/libfdt.a


# libdtc-host, dtc-host and fitdump using the same source
ifneq ($($(PKG)_SOURCE),$(DTC_HOST_SOURCE))
$(TOOLS_SOURCE_DOWNLOAD)
endif
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_NOP)

$($(PKG)_LIBFDT_BINARY): $($(PKG)_DIR)/.unpacked
	$(TOOLS_SUBMAKE) -f Makefile.freetz -C $(LIBDTC_HOST_DIR)/libfdt all \
		CC="$(TOOLS_CC)" \
		BITNESS="$(HOST_CFLAGS_FORCE_32BIT_CODE)"

$($(PKG)_BINARY): $($(PKG)_LIBFDT_BINARY)
	$(TOOLS_SUBMAKE) -f Makefile.freetz -C $(LIBDTC_HOST_DIR)/libfdt install \
		PREFIX="$(HOST_TOOLS_DIR)"

$(pkg)-precompiled: $($(PKG)_BINARY)


$(pkg)-clean:
	-$(MAKE) -f Makefile.freetz -C $(LIBDTC_HOST_DIR)/libfdt clean

$(pkg)-dirclean:
	$(RM) -r $(LIBDTC_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(HOST_TOOLS_DIR)/lib/libfdt* $(HOST_TOOLS_DIR)/include/*fdt*.h

$(TOOLS_FINISH)
