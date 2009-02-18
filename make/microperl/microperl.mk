# partly taken from www.buildroot.org
$(call PKG_INIT_BIN, 5.10.0)
$(PKG)_SOURCE:=perl-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=ftp://ftp.mpi-sb.mpg.de/pub/perl/CPAN/src/5.0
$(PKG)_DIR:=$(SOURCE_DIR)/perl-$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/microperl
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/sbin/microperl
$(PKG)_TARGET_MODULES:=$($(PKG)_TARGET_DIR)/.modules_installed
$(PKG)_TARGET_MODULES_DIR:=$($(PKG)_DEST_DIR)/usr/lib/perl5/5.10.0
$(PKG)_TARGET_MODS:=$(subst ",,$(FREETZ_PACKAGE_MICROPERL_MODULES))

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(MICROPERL_DIR) -f Makefile.micro \
		CC="$(TARGET_CC)" OPTIMIZE="$(TARGET_CFLAGS)" 

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_MODULES): $($(PKG)_DIR)/.unpacked
	mkdir -p $(MICROPERL_TARGET_MODULES_DIR)
	( \
		for i in $(patsubst %,$(MICROPERL_TARGET_MODULES_DIR)/%,$(dir $(MICROPERL_TARGET_MODS))); do \
			[ -d $$i ] || mkdir -p $$i; \
		done; \
		for i in $(MICROPERL_TARGET_MODS); do \
			cp -dpf $(MICROPERL_DIR)/lib/$$i $(MICROPERL_TARGET_MODULES_DIR)/$$i; \
		done; \
	)
	touch $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_MODULES)

$(pkg)-clean:
	-$(MAKE) -C $(MICROPERL_DIR) -f Makefile.micro clean
	-$(RM) -r $(MICROPERL_TARGET_MODULES_DIR)
	-$(RM) $(MICROPERL_TARGET_MODULES)

$(pkg)-uninstall:
	$(RM) $(MICROPERL_TARGET_BINARY)
	$(RM) -r $(MICROPERL_TARGET_MODULES_DIR)

$(PKG_FINISH)
