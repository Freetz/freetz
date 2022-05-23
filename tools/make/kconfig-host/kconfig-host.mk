$(call TOOLS_INIT, v5.18)
$(PKG)_SOURCE:=kconfig-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_SHA256:=5d2f909fa479710e83fc0f66e87ee53c9b34033abc5f2401479ca8bd0924e87a
$(PKG)_SITE:=git_archive@git://repo.or.cz/linux.git,scripts/basic,scripts/kconfig,scripts/Kbuild.include,scripts/Makefile.compiler,scripts/Makefile.build,scripts/Makefile.host,scripts/Makefile.lib,Documentation/kbuild/kconfig-language.rst,Documentation/kbuild/kconfig-macro-language.rst,Documentation/kbuild/kconfig.rst

$(PKG)_TARGET_DIR:=$(TOOLS_DIR)/kconfig
$(PKG)_TARGET_DEF := conf   mconf
$(PKG)_TARGET_PRG := conf   mconf      nconf   gconf   gconf.glade qconf
$(PKG)_TARGET_ARG := config menuconfig nconfig gconfig gconfig     xconfig
$(PKG)_TARGET_ALL := $(join $(KCONFIG_HOST_TARGET_ARG),$(patsubst %,--%,$(KCONFIG_HOST_TARGET_PRG)))

$(PKG)_PREREQ:=bison flex
$(PKG)_DEPENDS_ON:=


$(pkg)-source: $(DL_DIR)/$($(PKG)_SOURCE)
$(DL_DIR)/$($(PKG)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(KCONFIG_HOST_SOURCE) $(KCONFIG_HOST_SITE) $(KCONFIG_HOST_SOURCE_SHA256)

$(pkg)-unpacked: $($(PKG)_DIR)/.unpacked
$($(PKG)_DIR)/.unpacked: $(DL_DIR)/$($(PKG)_SOURCE) | $(TOOLS_SOURCE_DIR)
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xf $(DL_DIR)/$(KCONFIG_HOST_SOURCE)
	$(call APPLY_PATCHES,$(KCONFIG_HOST_MAKE_DIR)/patches,$(KCONFIG_HOST_DIR))
	$(if $(FREETZ_REAL_DEVELOPER_ONLY__BUTTONS),$(call APPLY_PATCHES,$(KCONFIG_HOST_MAKE_DIR)/patches/buttons,$(KCONFIG_HOST_DIR)))
	touch $@

$($(PKG)_DIR)/.prerequisites: $($(PKG)_DIR)/.unpacked
	@prmiss="";\
	for prereq in $(KCONFIG_HOST_PREREQ); do which $${prereq} &>/dev/null || prmiss="$${prmiss} $${prereq}"; done; \
	if [ -n "$${prmiss}" ]; then \
		for prereq in $${prmiss}; do echo "Prerequisite '$${prereq}' is missing!"; done; \
		echo "See https://freetz-ng.github.io/freetz-ng/PREREQUISITES for installation hints" && exit 1; \
	fi
	touch $@

$($(PKG)_TARGET_PRG:%=$($(PKG)_DIR)/scripts/kconfig/%): $($(PKG)_DIR)/.prerequisites
	$(TOOLS_SUBMAKE) -C $(KCONFIG_HOST_DIR) $(subst --$(notdir $@),,$(filter %--$(notdir $@),$(KCONFIG_HOST_TARGET_ALL)))

$(patsubst %,$($(PKG)_TARGET_DIR)/%,$($(PKG)_TARGET_PRG)): $($(PKG)_TARGET_DIR)/% : $($(PKG)_DIR)/scripts/kconfig/%
	$(INSTALL_FILE)

$(patsubst %,$(pkg)-%,$($(PKG)_TARGET_PRG)): $(pkg)-% : $($(PKG)_TARGET_DIR)/%
$(pkg)-gconf: $(pkg)-gconf.glade

$(pkg)-precompiled: $(patsubst %,$($(PKG)_TARGET_DIR)/%,$($(PKG)_TARGET_DEF))


$(pkg)-clean:
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

$(pkg)-dirclean:
	$(RM) -r $(KCONFIG_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r $(KCONFIG_HOST_TARGET_DIR)/


.PHONY: $(pkg)-source $(pkg)-unpacked
.PHONY: $(pkg) $(pkg)-conf $(pkg)-gconf $(pkg)-qconf
.PHONY: $(pkg)-clean $(pkg)-dirclean $(pkg)-distclean

$(TOOLS_FINISH)
