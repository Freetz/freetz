PACKAGE_LC:=ltrace
PACKAGE_UC:=LTRACE
LTRACE_SVN_REVISION:=77
$(PACKAGE_UC)_VERSION:=0.5_$(LTRACE_SVN_REVISION)
$(PACKAGE_INIT_BIN)
LTRACE_SOURCE:=ltrace-$(LTRACE_VERSION).tar.bz2
LTRACE_SITE:=http://dsmod.magenbrot.net
LTRACE_BINARY:=$(LTRACE_DIR)/ltrace
LTRACE_CONF:=$(LTRACE_DIR)/etc/ltrace.conf
LTRACE_TARGET_BINARY:=$(LTRACE_DEST_DIR)/usr/sbin/ltrace
LTRACE_TARGET_CONF:=$(LTRACE_DEST_DIR)/etc/ltrace.conf
LTRACE_PKG_VERSION:=0.1

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
$(PACKAGE_UNPACKED)
$(PACKAGE_CONFIGURED_CONFIGURE)

$($(PACKAGE_UC)_TARGET_CONF): $($(PACKAGE_UC)_DIR)/.unpacked
	mkdir -p $(dir $@)
	cp $(LTRACE_CONF) $(LTRACE_TARGET_CONF)

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(LTRACE_DIR) ARCH=mipsel

$($(PACKAGE_UC)_TARGET_BINARY): $($(PACKAGE_UC)_BINARY)
	$(INSTALL_BINARY_STRIP)

ltrace:

ltrace-precompiled: uclibc libelf-precompiled ltrace $($(PACKAGE_UC)_TARGET_BINARY) $($(PACKAGE_UC)_TARGET_CONF)

ltrace-clean:
	-$(MAKE) -C $(LTRACE_DIR) clean ARCH=mipsel
	rm -f $(PACKAGES_BUILD_DIR)/$(LTRACE_PKG_SOURCE)

ltrace-uninstall:
	rm -f $(LTRACE_TARGET_BINARY)
	rm -f $(LTRACE_TARGET_CONF)

$(PACKAGE_FINI)

