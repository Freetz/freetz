DTC_HOST_VERSION:=1.6.1
DTC_HOST_SOURCE:=dtc-$(DTC_HOST_VERSION).tar.xz
DTC_HOST_SOURCE_SHA256:=65cec529893659a49a89740bb362f507a3b94fc8cd791e76a8d6a2b6f3203473
DTC_HOST_SITE:=@KERNEL/software/utils/dtc

DTC_HOST_DIR:=$(TOOLS_SOURCE_DIR)/dtc-$(DTC_HOST_VERSION)
DTC_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/dtc-host

DTC_LIBFDT_HOST_DIR:=$(DTC_HOST_DIR)/libfdt


dtc-host-source: $(DL_DIR)/$(DTC_HOST_SOURCE)
$(DL_DIR)/$(DTC_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(DTC_HOST_SOURCE) $(DTC_HOST_SITE) $(DTC_HOST_SOURCE_SHA256)

dtc-host-unpacked: $(DTC_HOST_DIR)/.unpacked
$(DTC_HOST_DIR)/.unpacked: $(DL_DIR)/$(DTC_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(DTC_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(DTC_HOST_MAKE_DIR)/patches,$(DTC_HOST_DIR))
	touch $@

$(DTC_LIBFDT_HOST_DIR)/libfdt.a: $(DTC_HOST_DIR)/.unpacked
	$(TOOL_SUBMAKE) -f Makefile.freetz -C $(DTC_LIBFDT_HOST_DIR) all \
		CC="$(TOOLS_CC)" \
		BITNESS="$(HOST_CFLAGS_FORCE_32BIT_CODE)"
	touch -c $@

dtc-host-precompiled: $(DTC_LIBFDT_HOST_DIR)/libfdt.a


dtc-host-clean:
	-$(MAKE) -f Makefile.freetz -C $(DTC_LIBFDT_HOST_DIR) clean

dtc-host-dirclean:
	$(RM) -r $(DTC_HOST_DIR)

dtc-host-distclean: dtc-host-dirclean

