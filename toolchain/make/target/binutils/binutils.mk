BINUTILS_VERSION:=$(TARGET_TOOLCHAIN_BINUTILS_VERSION)
BINUTILS_SOURCE:=binutils-$(BINUTILS_VERSION).tar.bz2
BINUTILS_STABLE_SITE:=http://ftp.gnu.org/gnu/binutils
BINUTILS_DEVELOPER_SITE:=http://ftp.kernel.org/pub/linux/devel/binutils
BINUTILS_DIR:=$(TARGET_TOOLCHAIN_DIR)/binutils-$(BINUTILS_VERSION)
BINUTILS_MAKE_DIR:=$(TOOLCHAIN_DIR)/make/target/binutils


$(DL_DIR)/$(BINUTILS_SOURCE):
	wget -P $(DL_DIR) $(BINUTILS_STABLE_SITE)/$(BINUTILS_SOURCE) || \
	wget -P $(DL_DIR) $(BINUTILS_DEVELOPER_SITE)/$(BINUTILS_SOURCE)

$(BINUTILS_DIR)/.unpacked: $(DL_DIR)/$(BINUTILS_SOURCE)
	tar -C $(TARGET_TOOLCHAIN_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(BINUTILS_SOURCE)
	for i in $(BINUTILS_MAKE_DIR)/$(BINUTILS_VERSION)/*.patch; do \
                patch -d $(BINUTILS_DIR) -p1 < $$i; \
        done
	touch $@

$(BINUTILS_DIR)/.configured: $(BINUTILS_DIR)/.unpacked
	( cd $(BINUTILS_DIR); rm -f config.cache; \
		./configure \
		--prefix=$(TARGET_TOOLCHAIN_STAGING_DIR) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		$(DISABLE_NLS) \
	);
	touch $@

$(BINUTILS_DIR)/binutils/objdump: $(BINUTILS_DIR)/.configured
	$(MAKE) -C $(BINUTILS_DIR) all

$(TARGET_TOOLCHAIN_STAGING_DIR)/$(REAL_GNU_TARGET_NAME)/bin/ld: $(BINUTILS_DIR)/binutils/objdump
	$(MAKE) -C $(BINUTILS_DIR) install

binutils-dependancies:
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

binutils: binutils-dependancies $(TARGET_TOOLCHAIN_STAGING_DIR)/$(REAL_GNU_TARGET_NAME)/bin/ld

.PHONY: binutils binutils-dependancies
