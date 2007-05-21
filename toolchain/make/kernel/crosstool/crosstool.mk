CROSSTOOL_VERSION:=0.43
CROSSTOOL_SOURCE:=crosstool-$(CROSSTOOL_VERSION).tar.gz
CROSSTOOL_SITE:=http://www.kegel.com/crosstool
CROSSTOOL_DIR:=$(SOURCE_DIR)/crosstool-$(CROSSTOOL_VERSION)
CROSSTOOL_MAKE_DIR:=$(TOOLCHAIN_DIR)/make/kernel/crosstool
CROSSTOOL_COMPILER:=gcc-$(KERNEL_TOOLCHAIN_GCC_VERSION)-glibc-$(KERNEL_TOOLCHAIN_GLIBC_VERSION)

ifeq ($(strip $(DS_VERBOSITY_LEVEL)),0)
CROSSTOOL_VERBOSE:= \
	QUIET_EXTRACTIONS="y"; \
	export QUIET_EXTRACTIONS;
else
CROSSTOOL_VERBOSE:=
endif

CROSSTOOL_CONFIG:= $(CROSSTOOL_VERBOSE) \
	set -ex; \
	PARALLELMFLAGS="-j$(DS_JLEVEL)"; \
	TARBALLS_DIR="$(shell pwd)/$(DL_DIR)"; \
	RESULT_TOP="$(shell pwd)/$(TOOLCHAIN_BUILD_DIR)"; \
	GCC_LANGUAGES="c"; \
	export PARALLELMFLAGS TARBALLS_DIR RESULT_TOP GCC_LANGUAGES; \
	eval `cat mipsel.dat $(CROSSTOOL_COMPILER).dat`


$(DL_DIR)/$(CROSSTOOL_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(CROSSTOOL_SITE)/$(CROSSTOOL_SOURCE)

$(CROSSTOOL_DIR)/.unpacked: $(DL_DIR)/$(CROSSTOOL_SOURCE)
	mkdir -p $(SOURCE_DIR)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(CROSSTOOL_SOURCE)
	touch $@

$(CROSSTOOL_DIR)/.unpacked2: $(CROSSTOOL_DIR)/.unpacked
	( cd $(CROSSTOOL_DIR); \
		$(CROSSTOOL_CONFIG) \
		sh all.sh --nobuild --notest; \
	);
	for i in $(CROSSTOOL_MAKE_DIR)/patches/*.patch; do \
		[ -f $$i ] || continue; \
		patch -d $(CROSSTOOL_DIR)/build/mipsel-unknown-linux-gnu/$(CROSSTOOL_COMPILER) -p0 < $$i; \
	done
	touch $@

$(CROSSTOOL_DIR)/.installed: $(CROSSTOOL_DIR)/.unpacked2
	( cd $(CROSSTOOL_DIR); \
		unset LD_LIBRARY_PATH; \
		$(CROSSTOOL_CONFIG) \
		sh all.sh --nounpack --notest; \
	);
	touch $@
