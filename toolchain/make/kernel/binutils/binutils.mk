BINUTILS_KERNEL_VERSION:=$(KERNEL_TOOLCHAIN_BINUTILS_VERSION)
BINUTILS_KERNEL_SOURCE:=binutils-$(BINUTILS_KERNEL_VERSION).tar.bz2
BINUTILS_KERNEL_STABLE_SITE:=http://ftp.gnu.org/gnu/binutils
BINUTILS_KERNEL_DEVELOPER_SITE:=http://ftp.kernel.org/pub/linux/devel/binutils
BINUTILS_KERNEL_DIR:=$(KERNEL_TOOLCHAIN_DIR)/binutils-$(BINUTILS_KERNEL_VERSION)
BINUTILS_KERNEL_MAKE_DIR:=$(TOOLCHAIN_DIR)/make/kernel/binutils
BINUTILS_KERNEL_DIR1:=$(BINUTILS_KERNEL_DIR)-build

ifeq ($(strip $(FREETZ_STATIC_TOOLCHAIN)),y)
BINUTILS_KERNEL_EXTRA_MAKE_OPTIONS:="LDFLAGS=-all-static"
else
BINUTILS_KERNEL_EXTRA_MAKE_OPTIONS:=
endif

ifneq ($(strip $(DL_DIR)/$(BINUTILS_KERNEL_SOURCE)), $(strip $(DL_DIR)/$(BINUTILS_SOURCE)))
$(DL_DIR)/$(BINUTILS_KERNEL_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(BINUTILS_KERNEL_STABLE_SITE)/$(BINUTILS_KERNEL_SOURCE) || \
	wget -P $(DL_DIR) $(BINUTILS_KERNEL_DEVELOPER_SITE)/$(BINUTILS_KERNEL_SOURCE)
endif

$(BINUTILS_KERNEL_DIR)/.unpacked: $(DL_DIR)/$(BINUTILS_KERNEL_SOURCE)
	mkdir -p $(KERNEL_TOOLCHAIN_DIR)
	tar -C $(KERNEL_TOOLCHAIN_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(BINUTILS_KERNEL_SOURCE)
	for i in $(BINUTILS_KERNEL_MAKE_DIR)/$(BINUTILS_KERNEL_VERSION)/*.patch; do \
		$(PATCH_TOOL) $(BINUTILS_KERNEL_DIR) $$i; \
	done
	touch $@

$(BINUTILS_KERNEL_DIR1)/.configured: $(BINUTILS_KERNEL_DIR)/.unpacked
	mkdir -p $(BINUTILS_KERNEL_DIR1)
	( cd $(BINUTILS_KERNEL_DIR1); \
		CC="$(HOSTCC)" \
		$(BINUTILS_KERNEL_DIR)/configure \
		--prefix=$(KERNEL_TOOLCHAIN_STAGING_DIR) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(REAL_GNU_KERNEL_NAME) \
		$(DISABLE_NLS) \
		--disable-werror \
		--without-headers \
	);
	touch $@

$(BINUTILS_KERNEL_DIR1)/binutils/objdump: $(BINUTILS_KERNEL_DIR1)/.configured
	$(MAKE) -C $(BINUTILS_KERNEL_DIR1) configure-host
	$(MAKE) $(BINUTILS_KERNEL_EXTRA_MAKE_OPTIONS) -C $(BINUTILS_KERNEL_DIR1) all

$(KERNEL_TOOLCHAIN_STAGING_DIR)/$(REAL_GNU_KERNEL_NAME)/bin/ld: $(BINUTILS_KERNEL_DIR1)/binutils/objdump
	$(MAKE) -C $(BINUTILS_KERNEL_DIR1) install

binutils-kernel-dependancies:
	@if ! which bison > /dev/null ; then \
		echo -e "\n\nYou must install 'bison' on your build machine\n"; \
		exit 1; \
	fi;
	@if ! which flex > /dev/null ; then \
		echo -e "\n\nYou must install 'flex' on your build machine\n"; \
		exit 1; \
	fi;
	@if ! which msgfmt > /dev/null ; then \
		echo -e "\n\nYou must install 'gettext' on your build machine\n"; \
		exit 1; \
	fi;

binutils-kernel-source: $(DL_DIR)/$(BINUTILS_KERNEL_SOURCE)

binutils-kernel-clean:
	rm -rf $(KERNEL_TOOLCHAIN_STAGING_DIR)/usr/bin/*{ar,as,ld,nm,objdump,ranlib,strip} \
	$(KERNEL_TOOLCHAIN_STAGING_DIR)/usr/lib/{libiberty*,ldscripts}
	-$(MAKE) -C $(BINUTILS_KERNEL_DIR1) DESTDIR=$(KERNEL_TOOLCHAIN_STAGING_DIR) \
		tooldir=/usr build_tooldir=/usr uninstall
	-$(MAKE) -C $(BINUTILS_KERNEL_DIR1) clean
			    

binutils-kernel-dirclean:
	rm -rf $(BINUTILS_KERNEL_DIR1)

binutils-kernel: binutils-kernel-dependancies $(KERNEL_TOOLCHAIN_STAGING_DIR)/$(REAL_GNU_KERNEL_NAME)/bin/ld

.PHONY: binutils binutils-kernel-dependancies