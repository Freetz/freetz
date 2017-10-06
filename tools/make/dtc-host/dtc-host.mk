DTC_HOST_VERSION:=1.4.5
DTC_HOST_SOURCE:=dtc-$(DTC_HOST_VERSION).tar.xz
DTC_HOST_SOURCE_SHA256:=042c7164806af34069d13ede59d85b8156d09f179f721c516dc37712d3a0f621
DTC_HOST_SITE:=@KERNEL/software/utils/dtc

DTC_HOST_DIR:=$(TOOLS_SOURCE_DIR)/dtc-$(DTC_HOST_VERSION)
DTC_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/dtc-host

DTC_LIBFDT_HOST_DIR:=$(DTC_HOST_DIR)/libfdt

dtc-host-source: $(DL_DIR)/$(DTC_HOST_SOURCE)
$(DL_DIR)/$(DTC_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(DTC_HOST_SOURCE) $(DTC_HOST_SITE) $(DTC_HOST_SOURCE_SHA256)

dtc-host-unpacked: $(DTC_HOST_DIR)/.unpacked
$(DTC_HOST_DIR)/.unpacked: $(DL_DIR)/$(DTC_HOST_SOURCE) | $(TOOLS_SOURCE_DIR)
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xf $(DL_DIR)/$(DTC_HOST_SOURCE)
	$(call APPLY_PATCHES,$(DTC_HOST_MAKE_DIR)/patches,$(DTC_HOST_DIR))
	touch $@

$(DTC_LIBFDT_HOST_DIR)/libfdt.a: $(DTC_HOST_DIR)/.unpacked
	$(MAKE) -f Makefile.freetz -C $(DTC_LIBFDT_HOST_DIR) \
		CC="$(TOOLS_CC)"
	touch -c $@

dtc-host: $(DTC_LIBFDT_HOST_DIR)/libfdt.a

dtc-host-clean:
	-$(MAKE) -f Makefile.freetz -C $(DTC_LIBFDT_HOST_DIR) clean

dtc-host-dirclean:
	$(RM) -r $(DTC_HOST_DIR)

dtc-host-distclean: dtc-host-dirclean
