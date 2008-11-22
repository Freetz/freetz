LTRACE_SVN_REVISION:=81
$(call PKG_INIT_BIN, 0.5_$(LTRACE_SVN_REVISION))
$(PKG)_SOURCE:=ltrace-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://freetz.magenbrot.net
$(PKG)_BINARY:=$($(PKG)_DIR)/ltrace
$(PKG)_CONF:=$($(PKG)_DIR)/etc/ltrace.conf
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/ltrace
$(PKG)_TARGET_CONF:=$($(PKG)_DEST_DIR)/etc/ltrace.conf

# Remarks:
#   - LTRACE_SOURCE is created like this:
#     svn export -r 81 svn://svn.debian.org/ltrace/ltrace/trunk ltrace-0.5_81
#     tar cvjf ltrace-0.5_81.tar.bz2 ltrace-0.5_81/
#   - Because we do not want the build process to depend on the availability
#     of a Subversion client (svn checkout), we provide the ltrace source
#     package as a download on Freetz mirrors and use DL_TOOL to download it.

$(PKG)_DEPENDS_ON := libelf	

$(PKG)_CONFIGURE_PRE_CMDS += ./autogen.sh ;
$(PKG)_CONFIGURE_PRE_CMDS += ( cd sysdeps/linux-gnu/mipsel; \
					../mksyscallent $(TARGET_MAKE_PATH)/../include/asm/unistd.h > syscallent.h; \
					../mksignalent $(TARGET_MAKE_PATH)/../include/asm/signal.h > signalent.h; );

$(PKG)_CONFIGURE_ENV += LD="$(TARGET_LD)"


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_CONF): $($(PKG)_DIR)/.unpacked

$($(PKG)_TARGET_CONF): $($(PKG)_CONF)
	mkdir -p $(dir $@)
	cp $< $@

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(LTRACE_DIR) ARCH=mipsel

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_CONF)

$(pkg)-clean:
	-$(MAKE) -C $(LTRACE_DIR) clean ARCH=mipsel

$(pkg)-uninstall:
	rm -f $(LTRACE_TARGET_BINARY)
	rm -f $(LTRACE_TARGET_CONF)

$(PKG_FINISH)
