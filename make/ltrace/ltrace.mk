PACKAGE_LC:=ltrace
PACKAGE_UC:=LTRACE
LTRACE_SVN_REVISION:=77
LTRACE_VERSION:=0.5_$(LTRACE_SVN_REVISION)
LTRACE_SOURCE:=ltrace-$(LTRACE_VERSION).tar.bz2
LTRACE_SITE:=http://dsmod.magenbrot.net
LTRACE_MAKE_DIR:=$(MAKE_DIR)/ltrace
LTRACE_DIR:=$(SOURCE_DIR)/ltrace-$(LTRACE_VERSION)
LTRACE_BINARY:=$(LTRACE_DIR)/ltrace
LTRACE_CONF:=$(LTRACE_DIR)/etc/ltrace.conf
LTRACE_TARGET_DIR:=$(PACKAGES_DIR)/ltrace-$(LTRACE_VERSION)
LTRACE_TARGET_BINARY:=$(LTRACE_TARGET_DIR)/root/usr/sbin/ltrace
LTRACE_TARGET_CONF:=$(LTRACE_TARGET_DIR)/root/etc/ltrace.conf
LTRACE_PKG_VERSION:=0.1
LTRACE_STARTLEVEL=40

# Remarks:
#   - LTRACE_SOURCE is created like this:
#     svn export -r 77 svn://svn.debian.org/ltrace/ltrace/trunk ltrace-0.5_77
#     tar cvjf ltrace-0.5_77.tar.bz2 ltrace-0.5_77/
#   - Because we do not want the build process to depend on the availability
#     of a Subversion client (svn checkout), we provide the ltrace source
#     package as a download on DS-Mod mirrors and use DL_TOOL to download it.
	
$(PACKAGE_UC)_CONFIGURE_PRE_CMDS += ./autogen.sh ;
$(PACKAGE_UC)_CONFIGURE_PRE_CMDS += ( cd /sysdeps/linux-gnu/mipsel; \
					../mksyscallent $(TARGET_MAKE_PATH)/../include/asm/unistd.h > syscallent.h; \
					../mksignalent $(TARGET_MAKE_PATH)/../include/asm/signal.h > signalent.h; );
$(PACKAGE_UC)_CONFIGURE_ENV += LD="$(TARGET_LD)"


$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_BIN_UNPACKED)
$(PACKAGE_CONFIGURED_CONFIGURE)

$(PACKAGES_DIR)/.ltrace-$(LTRACE_VERSION): $(DL_DIR)/$(LTRACE_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(LTRACE_PKG_SOURCE)
	@touch $@

$(LTRACE_CONF): $(LTRACE_DIR)/.unpacked
	touch $@

$(LTRACE_TARGET_CONF): $(LTRACE_CONF)
	mkdir -p $(dir $(LTRACE_TARGET_CONF))
	cp $(LTRACE_CONF) $(LTRACE_TARGET_CONF)

$(LTRACE_BINARY): $(LTRACE_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(LTRACE_DIR) ARCH=mipsel

$(LTRACE_TARGET_BINARY): $(LTRACE_BINARY)
	mkdir -p $(dir $(LTRACE_TARGET_BINARY))
	$(INSTALL_BINARY_STRIP)

ltrace:

ltrace-precompiled: uclibc libelf-precompiled ltrace $(LTRACE_TARGET_BINARY) $(LTRACE_TARGET_CONF)

ltrace-source: $(LTRACE_DIR)/.unpacked

ltrace-clean:
	-$(MAKE) -C $(LTRACE_DIR) clean ARCH=mipsel
	rm -f $(PACKAGES_BUILD_DIR)/$(LTRACE_PKG_SOURCE)

ltrace-dirclean:
	rm -rf $(LTRACE_DIR)
	rm -rf $(PACKAGES_DIR)/ltrace-$(LTRACE_VERSION)

ltrace-uninstall:
	rm -f $(LTRACE_TARGET_BINARY)
	rm -f $(LTRACE_TARGET_CONF)

$(PACKAGE_LIST)

