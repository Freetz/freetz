$(call TOOL_INIT, v5.17)
$(TOOL)_SOURCE:=kconfig-$($(TOOL)_VERSION).tar.xz
$(TOOL)_SOURCE_SHA256:=152b350cbcfbec4586098be0647eb350fbd3c7e27e4bae153c66c19c07329379
$(TOOL)_SITE:=git_archive@git://repo.or.cz/linux.git,scripts/basic,scripts/kconfig,scripts/Kbuild.include,scripts/Makefile.compiler,scripts/Makefile.build,scripts/Makefile.host,scripts/Makefile.lib,Documentation/kbuild/kconfig-language.rst,Documentation/kbuild/kconfig-macro-language.rst,Documentation/kbuild/kconfig.rst

$(TOOL)_TARGET_DIR:=$(TOOLS_DIR)/kconfig
$(TOOL)_PREREQ:=bison flex


$(tool)-source: $(DL_DIR)/$($(TOOL)_SOURCE)
$(DL_DIR)/$($(TOOL)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(KCONFIG_HOST_SOURCE) $(KCONFIG_HOST_SITE) $(KCONFIG_HOST_SOURCE_SHA256)

$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(DL_DIR)/$($(TOOL)_SOURCE) | $(TOOLS_SOURCE_DIR)
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xf $(DL_DIR)/$(KCONFIG_HOST_SOURCE)
	$(call APPLY_PATCHES,$(KCONFIG_HOST_MAKE_DIR)/patches,$(KCONFIG_HOST_DIR))
	$(if $(FREETZ_REAL_DEVELOPER_ONLY__BUTTONS),$(call APPLY_PATCHES,$(KCONFIG_HOST_MAKE_DIR)/patches/buttons,$(KCONFIG_HOST_DIR)))
	touch $@

$($(TOOL)_DIR)/.prerequisites: $($(TOOL)_DIR)/.unpacked
	@prmiss="";\
	for prereq in $(KCONFIG_HOST_PREREQ); do which $${prereq} &>/dev/null || prmiss="$${prmiss} $${prereq}"; done; \
	if [ -n "$${prmiss}" ]; then \
		for prereq in $${prmiss}; do echo "Prerequisite '$${prereq}' is missing!"; done; \
		echo "See https://freetz-ng.github.io/freetz-ng/PREREQUISITES for installation hints" && exit 1; \
	fi
	touch $@

$($(TOOL)_DIR)/scripts/kconfig/conf: $($(TOOL)_DIR)/.prerequisites
	$(TOOL_SUBMAKE) -C $(KCONFIG_HOST_DIR) config

$($(TOOL)_DIR)/scripts/kconfig/mconf: $($(TOOL)_DIR)/.prerequisites
	$(TOOL_SUBMAKE) -C $(KCONFIG_HOST_DIR) menuconfig

$($(TOOL)_TARGET_DIR)/conf: $($(TOOL)_DIR)/scripts/kconfig/conf
	$(INSTALL_FILE)

$($(TOOL)_TARGET_DIR)/mconf: $($(TOOL)_DIR)/scripts/kconfig/mconf
	$(INSTALL_FILE)

$(tool)-precompiled: $($(TOOL)_TARGET_DIR)/conf $($(TOOL)_TARGET_DIR)/mconf


$(tool)-clean:
	$(RM) \
		$(KCONFIG_HOST_DIR)/scripts/basic/.*.cmd \
		$(KCONFIG_HOST_DIR)/scripts/kconfig/.*.cmd \
		$(KCONFIG_HOST_DIR)/scripts/kconfig/lxdialog/.*.cmd \
		$(KCONFIG_HOST_DIR)/scripts/kconfig/*.o \
		$(KCONFIG_HOST_DIR)/scripts/kconfig/lxdialog/*.o \
		$(KCONFIG_HOST_DIR)/scripts/kconfig/zconf.*.c \
		$(KCONFIG_HOST_DIR)/scripts/basic/fixdep \
		$(KCONFIG_HOST_DIR)/scripts/kconfig/conf \
		$(KCONFIG_HOST_DIR)/scripts/kconfig/mconf

$(tool)-dirclean:
	$(RM) -r $(KCONFIG_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean
	$(RM) -r $(KCONFIG_HOST_TARGET_DIR)/

.PHONY: $(tool)-source $(tool)-unpacked kconfig-host $(tool)-clean $(tool)-dirclean $(tool)-distclean

$(TOOL_FINISH)
