$(call TOOL_INIT, v5.18)
$(TOOL)_SOURCE:=kconfig-$($(TOOL)_VERSION).tar.xz
$(TOOL)_SOURCE_SHA256:=5d2f909fa479710e83fc0f66e87ee53c9b34033abc5f2401479ca8bd0924e87a
$(TOOL)_SITE:=git_archive@git://repo.or.cz/linux.git,scripts/basic,scripts/kconfig,scripts/Kbuild.include,scripts/Makefile.compiler,scripts/Makefile.build,scripts/Makefile.host,scripts/Makefile.lib,Documentation/kbuild/kconfig-language.rst,Documentation/kbuild/kconfig-macro-language.rst,Documentation/kbuild/kconfig.rst

$(TOOL)_TARGET_DIR:=$(TOOLS_DIR)/kconfig
$(TOOL)_PREREQ:=bison flex

$(TOOL)_TARGET_DEF := conf   mconf
$(TOOL)_TARGET_PRG := conf   mconf      nconf   gconf   gconf.glade qconf
$(TOOL)_TARGET_ARG := config menuconfig nconfig gconfig gconfig     xconfig
$(TOOL)_TARGET_ALL := $(join $(KCONFIG_HOST_TARGET_ARG),$(patsubst %,--%,$(KCONFIG_HOST_TARGET_PRG)))

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

$($(TOOL)_TARGET_PRG:%=$($(TOOL)_DIR)/scripts/kconfig/%): $($(TOOL)_DIR)/.prerequisites
	$(TOOL_SUBMAKE) -C $(KCONFIG_HOST_DIR) $(subst --$(notdir $@),,$(filter %--$(notdir $@),$(KCONFIG_HOST_TARGET_ALL)))

$(patsubst %,$($(TOOL)_TARGET_DIR)/%,$($(TOOL)_TARGET_PRG)): $($(TOOL)_TARGET_DIR)/% : $($(TOOL)_DIR)/scripts/kconfig/%
	$(INSTALL_FILE)

$(patsubst %,$(tool)-%,$($(TOOL)_TARGET_PRG)): $(tool)-% : $($(TOOL)_TARGET_DIR)/%
$(tool)-gconf: $(tool)-gconf.glade

$(tool)-precompiled: $(patsubst %,$($(TOOL)_TARGET_DIR)/%,$($(TOOL)_TARGET_DEF))


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
		$(KCONFIG_HOST_DIR)/scripts/kconfig/gconf.glade \
		$(KCONFIG_HOST_DIR)/scripts/kconfig/qconf \
		$(KCONFIG_HOST_DIR)/scripts/kconfig/gconf \
		$(KCONFIG_HOST_DIR)/scripts/kconfig/nconf \
		$(KCONFIG_HOST_DIR)/scripts/kconfig/mconf

$(tool)-dirclean:
	$(RM) -r $(KCONFIG_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean
	$(RM) -r $(KCONFIG_HOST_TARGET_DIR)/


.PHONY: $(tool)-source $(tool)-unpacked
.PHONY: $(tool) $(tool)-conf $(tool)-gconf $(tool)-qconf
.PHONY: $(tool)-clean $(tool)-dirclean $(tool)-distclean

$(TOOL_FINISH)
