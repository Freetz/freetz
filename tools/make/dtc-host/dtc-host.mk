$(call TOOLS_INIT, 1.6.1)
$(PKG)_SOURCE:=dtc-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_SHA256:=65cec529893659a49a89740bb362f507a3b94fc8cd791e76a8d6a2b6f3203473
$(PKG)_SITE:=@KERNEL/software/utils/dtc

$(PKG)_LIBFDT_DIR:=$($(PKG)_DIR)/libfdt


$(pkg)-source: $(DL_DIR)/$($(PKG)_SOURCE)
$(DL_DIR)/$($(PKG)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(DTC_HOST_SOURCE) $(DTC_HOST_SITE) $(DTC_HOST_SOURCE_SHA256)

$(TOOLS_UNPACKED)

$($(PKG)_LIBFDT_DIR)/libfdt.a: $($(PKG)_DIR)/.unpacked
	$(TOOLS_SUBMAKE) -f Makefile.freetz -C $(DTC_HOST_LIBFDT_DIR) all \
		CC="$(TOOLS_CC)" \
		BITNESS="$(HOST_CFLAGS_FORCE_32BIT_CODE)"
	touch -c $@

$(pkg)-precompiled: $($(PKG)_LIBFDT_DIR)/libfdt.a


$(pkg)-clean:
	-$(MAKE) -f Makefile.freetz -C $(DTC_HOST_LIBFDT_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(DTC_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean

$(TOOLS_FINISH)
