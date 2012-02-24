$(call PKG_INIT_BIN, 2012.55)
#$(PKG)_SOURCE:=$(pkg)_$($(PKG)_VERSION).orig.tar.gz 
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=44836e5a0419ba12557f9ea46880077e
#$(PKG)_SITE:=http://ftp.debian.org/debian/pool/main/d/dropbear 
$(PKG)_SITE:=http://matt.ucc.asn.au/dropbear/releases

$(PKG)_BINARY:=$($(PKG)_DIR)/dropbearmulti
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/dropbearmulti

$(PKG)_STARTLEVEL=30

ifeq ($(strip $(FREETZ_PACKAGE_DROPBEAR_SERVER_ONLY)),y)
$(PKG)_MAKE_OPTIONS:=PROGRAMS="dropbear dropbearkey" MULTI=1
$(PKG)_NOT_INCLUDED := $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,ssh scp)
else
$(PKG)_MAKE_OPTIONS:=PROGRAMS="dropbear dbclient dropbearkey scp" MULTI=1 SCPPROGRESS=1
endif

$(PKG)_CPPFLAGS:=
ifeq ($(strip $(FREETZ_PACKAGE_DROPBEAR_SFTP_SERVER)),y)
$(PKG)_CPPFLAGS+=-DSFTPSERVER_PATH='\"/usr/lib/sftp-server\"'
endif
ifeq ($(strip $(FREETZ_PACKAGE_DROPBEAR_STANDALONE)),y)
$(PKG)_CPPFLAGS:=-DSFTPSERVER_PATH='\"/var/tmp/sftp-server\"'
$(PKG)_CPPFLAGS+=-DDSS_PRIV_FILENAME='\"/var/tmp/dss_host_key\"'
$(PKG)_CPPFLAGS+=-DRSA_PRIV_FILENAME='\"/var/tmp/rsa_host_key\"'
$(PKG)_CPPFLAGS+=-DDB_NONFREETZ
endif
ifeq ($(strip $(FREETZ_PACKAGE_DROPBEAR_DISABLE_HOST_LOOKUP)),y)
$(PKG)_CPPFLAGS+=-DNO_HOST_LOOKUP
endif

ifeq ($(strip $(FREETZ_PACKAGE_DROPBEAR_WITH_ZLIB)),y)
$(PKG)_DEPENDS_ON := zlib
endif

ifeq ($(strip $(FREETZ_PACKAGE_DROPBEAR_STATIC)),y)
$(PKG)_MAKE_OPTIONS+= STATIC=1
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DROPBEAR_SERVER_ONLY
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DROPBEAR_WITH_ZLIB
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DROPBEAR_SFTP_SERVER
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DROPBEAR_DISABLE_HOST_LOOKUP
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DROPBEAR_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DROPBEAR_STANDALONE

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_DROPBEAR_WITH_ZLIB),,--disable-zlib)
$(PKG)_CONFIGURE_OPTIONS += --disable-pam
$(PKG)_CONFIGURE_OPTIONS += --enable-openpty
$(PKG)_CONFIGURE_OPTIONS += --enable-syslog
$(PKG)_CONFIGURE_OPTIONS += --enable-shadow
$(PKG)_CONFIGURE_OPTIONS += --disable-lastlog
$(PKG)_CONFIGURE_OPTIONS += --disable-utmp
$(PKG)_CONFIGURE_OPTIONS += --disable-utmpx
$(PKG)_CONFIGURE_OPTIONS += --disable-wtmp
$(PKG)_CONFIGURE_OPTIONS += --disable-wtmpx
$(PKG)_CONFIGURE_OPTIONS += --disable-loginfunc
$(PKG)_CONFIGURE_OPTIONS += --disable-pututline
$(PKG)_CONFIGURE_OPTIONS += --disable-pututxline

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(DROPBEAR_DIR) \
		$(DROPBEAR_MAKE_OPTIONS) CPPFLAGS="$(DROPBEAR_CPPFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(DROPBEAR_DIR) clean
	$(RM) $(DROPBEAR_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(DROPBEAR_TARGET_BINARY)

$(PKG_FINISH)
