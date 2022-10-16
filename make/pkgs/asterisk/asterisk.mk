$(call PKG_INIT_BIN, 11.25.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=beb63953cb61b9822fc8f1d79842d821c5147f2a2944941d54a02f2e5fd4db20
$(PKG)_SITE:=http://downloads.asterisk.org/pub/telephony/asterisk/releases

$(PKG)_CATEGORY:=Unstable

$(PKG)_CONFIG_DIR:=/mod/etc/asterisk
$(PKG)_MODULES_DIR:=/usr/lib/asterisk/modules
$(PKG)_INSTALL_DIR:=$($(PKG)_DIR)/_install
$(PKG)_INSTALL_DIR_ABSOLUTE:=$(abspath $($(PKG)_INSTALL_DIR))

$(PKG)_BINARY_BUILD_DIR  := $($(PKG)_INSTALL_DIR)/usr/sbin/asterisk
$(PKG)_BINARY_TARGET_DIR := $($(PKG)_DEST_DIR)/usr/sbin/asterisk

include $(MAKE_DIR)/asterisk/asterisk-modules.mk.in
$(PKG)_MODULES := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_MODULES_ALL))
ifneq ($(strip $(FREETZ_PACKAGE_ASTERISK_EMBED_MODULES)),y)
$(PKG)_MODULES_BUILD_DIR := $($(PKG)_MODULES:%=$($(PKG)_INSTALL_DIR)$($(PKG)_MODULES_DIR)/%.so)
$(PKG)_MODULES_TARGET_DIR := $($(PKG)_MODULES:%=$($(PKG)_DEST_DIR)$($(PKG)_MODULES_DIR)/%.so)
$(PKG)_EXCLUDED += $(patsubst %,$($(PKG)_DEST_DIR)$($(PKG)_MODULES_DIR)/%.so,$(filter-out $($(PKG)_MODULES),$($(PKG)_MODULES_ALL)))
endif

$(PKG)_BUILD_PREREQ += svn xml2-config

$(PKG)_DEPENDS_ON += curl
$(PKG)_DEPENDS_ON += iksemel
$(PKG)_DEPENDS_ON += libgsm
$(PKG)_DEPENDS_ON += ncurses
$(PKG)_DEPENDS_ON += openssl
$(PKG)_DEPENDS_ON += pjproject2
$(PKG)_DEPENDS_ON += popt
$(PKG)_DEPENDS_ON += spandsp
$(PKG)_DEPENDS_ON += speex
$(PKG)_DEPENDS_ON += sqlite
$(PKG)_DEPENDS_ON += srtp
$(PKG)_DEPENDS_ON += zlib
ifeq ($(strip $(FREETZ_TARGET_UCLIBC_0_9_28)),y)
$(PKG)_DEPENDS_ON += iconv
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_ASTERISK_LOWMEMORY
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_ASTERISK_DEBUG
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_ASTERISK_WITH_BACKTRACE
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_ASTERISK_EMBED_MODULES
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_ASTERISK_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION
ifeq ($(strip $(FREETZ_PACKAGE_ASTERISK_EMBED_MODULES)),y)
$(PKG)_REBUILD_SUBOPTS += $(foreach module,$($(PKG)_MODULES_ALL),FREETZ_PACKAGE_ASTERISK_$(call TOUPPER_NAME,$(module)))
endif

# Remove internal pjproject version to ensure that it is not used.
# We use pjproject version modified by asterisk developers (contains shared libraries support).
$(PKG)_CONFIGURE_PRE_CMDS += $(RM) -r res/pjproject;

$(PKG)_CONFIGURE_PRE_CMDS += $(if $(FREETZ_PACKAGE_ASTERISK_STATIC),$(SED) -i -r -e 's|-ltiff|$$$$($$$$PKG_CONFIG libtiff-4 --libs-only-l --static) -lm|g' ./configure;)

$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --disable-xmldoc
$(PKG)_CONFIGURE_OPTIONS += --disable-asteriskssl

$(PKG)_CONFIGURE_OPTIONS += --with-asound=no
$(PKG)_CONFIGURE_OPTIONS += --with-avcodec=no
$(PKG)_CONFIGURE_OPTIONS += --with-bfd=no
$(PKG)_CONFIGURE_OPTIONS += --with-bluetooth=no
$(PKG)_CONFIGURE_OPTIONS += --with-cap=no
$(PKG)_CONFIGURE_OPTIONS += --with-cpg=no
$(PKG)_CONFIGURE_OPTIONS += --with-crypto="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-curses=no
$(PKG)_CONFIGURE_OPTIONS += --with-dahdi=no
$(PKG)_CONFIGURE_OPTIONS += --with-execinfo=$(if $(FREETZ_PACKAGE_ASTERISK_WITH_BACKTRACE),"$(TARGET_TOOLCHAIN_STAGING_DIR)/usr",no)
$(PKG)_CONFIGURE_OPTIONS += --with-gmime=no
$(PKG)_CONFIGURE_OPTIONS += --with-gsm="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-gtk2=no
$(PKG)_CONFIGURE_OPTIONS += --with-h323=no
$(PKG)_CONFIGURE_OPTIONS += --with-hoard=no
$(PKG)_CONFIGURE_OPTIONS += --with-ical=no
$(PKG)_CONFIGURE_OPTIONS += --with-iconv=yes
$(PKG)_CONFIGURE_OPTIONS += --with-iksemel="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-ilbc=no
$(PKG)_CONFIGURE_OPTIONS += --with-imap=no
$(PKG)_CONFIGURE_OPTIONS += --with-inotify=no
$(PKG)_CONFIGURE_OPTIONS += --with-iodbc=no
$(PKG)_CONFIGURE_OPTIONS += --with-isdnnet=no
$(PKG)_CONFIGURE_OPTIONS += --with-jack=no
$(PKG)_CONFIGURE_OPTIONS += --with-kqueue=no
$(PKG)_CONFIGURE_OPTIONS += --with-ldap=no
$(PKG)_CONFIGURE_OPTIONS += --with-libcurl="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
#$(PKG)_CONFIGURE_OPTIONS += --with-libedit=no # use internal libedit
$(PKG)_CONFIGURE_OPTIONS += --with-libxml2=no
$(PKG)_CONFIGURE_OPTIONS += --with-ltdl=no
$(PKG)_CONFIGURE_OPTIONS += --with-lua=no
$(PKG)_CONFIGURE_OPTIONS += --with-misdn=no
$(PKG)_CONFIGURE_OPTIONS += --with-mysqlclient=no
$(PKG)_CONFIGURE_OPTIONS += --with-nbs=no
$(PKG)_CONFIGURE_OPTIONS += --with-ncurses="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-neon29=no
$(PKG)_CONFIGURE_OPTIONS += --with-neon=no
$(PKG)_CONFIGURE_OPTIONS += --with-netsnmp=no
$(PKG)_CONFIGURE_OPTIONS += --with-newt=no
$(PKG)_CONFIGURE_OPTIONS += --with-ogg=no
$(PKG)_CONFIGURE_OPTIONS += --with-openr2=no
$(PKG)_CONFIGURE_OPTIONS += --with-osptk=no
$(PKG)_CONFIGURE_OPTIONS += --with-oss=no
$(PKG)_CONFIGURE_OPTIONS += --with-popt="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-portaudio=no
$(PKG)_CONFIGURE_OPTIONS += --with-postgres=no
$(PKG)_CONFIGURE_OPTIONS += --with-pri=no
$(PKG)_CONFIGURE_OPTIONS += --with-pwlib=no
$(PKG)_CONFIGURE_OPTIONS += --with-radius=no
$(PKG)_CONFIGURE_OPTIONS += --with-resample=no
$(PKG)_CONFIGURE_OPTIONS += --with-SDL_image=no
$(PKG)_CONFIGURE_OPTIONS += --with-sdl=no
$(PKG)_CONFIGURE_OPTIONS += --with-sounds-cache=no
$(PKG)_CONFIGURE_OPTIONS += --with-spandsp="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-speexdsp="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-speex="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-sqlite3="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-sqlite=no
$(PKG)_CONFIGURE_OPTIONS += --with-srtp="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-SRTP_SHUTDOWN="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-ss7=no
$(PKG)_CONFIGURE_OPTIONS += --with-ssl="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-suppserv=no
$(PKG)_CONFIGURE_OPTIONS += --with-tds=no
$(PKG)_CONFIGURE_OPTIONS += --with-termcap=no
$(PKG)_CONFIGURE_OPTIONS += --with-timerfd=$(if $(FREETZ_PACKAGE_ASTERISK_WITH_TIMERFD),"$(TARGET_TOOLCHAIN_STAGING_DIR)/usr",no)
$(PKG)_CONFIGURE_OPTIONS += --with-tinfo=no
$(PKG)_CONFIGURE_OPTIONS += --with-tonezone=no
$(PKG)_CONFIGURE_OPTIONS += --with-unixodbc=no
$(PKG)_CONFIGURE_OPTIONS += --with-uuid=no
$(PKG)_CONFIGURE_OPTIONS += --with-vorbis=no
$(PKG)_CONFIGURE_OPTIONS += --with-vpb=no
$(PKG)_CONFIGURE_OPTIONS += --with-x11=no
$(PKG)_CONFIGURE_OPTIONS += --with-z="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"

$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/mod/etc

ifeq ($(or $(strip $(FREETZ_TARGET_UCLIBC_0_9_28)),$(strip $(FREETZ_TARGET_UCLIBC_0_9_29))),y)
$(PKG)_CONFIGURE_ENV += ac_cv_func_newlocale=no
endif

$(PKG)_DEBUG_CFLAGS := -O0 -g -DDEBUG

$(PKG)_MAKE_OPTIONS += -C $(ASTERISK_DIR)
$(PKG)_MAKE_OPTIONS += NOISY_BUILD=yes
$(PKG)_MAKE_OPTIONS += DEBUG="$(if $(FREETZ_PACKAGE_ASTERISK_DEBUG),$(ASTERISK_DEBUG_CFLAGS))"
$(PKG)_MAKE_OPTIONS += OPTIMIZE="$(if $(FREETZ_PACKAGE_ASTERISK_DEBUG),,$(filter -O%,$(TARGET_CFLAGS)))"
$(PKG)_MAKE_OPTIONS += ASTCFLAGS="-fno-strict-aliasing"
$(PKG)_MAKE_OPTIONS += AR="$(TARGET_AR)"
$(PKG)_MAKE_OPTIONS += RANLIB="$(TARGET_RANLIB)"
$(PKG)_MAKE_OPTIONS += LD="$(TARGET_LD)"
$(PKG)_MAKE_OPTIONS += PJPROJECT_BUILD_MAK_DIR="$(abspath $(PJPROJECT2_DIR))"

$(PKG)_CATEGORY_PREFIXES := app|bridge|cdr|cel|chan|codec|format|func|pbx|res
$(PKG)_CATEGORY_DIRS     := addons apps bridges cdr cel channels codecs formats funcs pbx res
$(PKG)_EMBED_CATEGORIES  := $(foreach cat,$($(PKG)_CATEGORY_DIRS),$(call TOUPPER_NAME,$(cat))) TEST

# $(1): variable name
# $(2): value (yes or no)
# $(3): menuselect file
define $(pkg)_set_option_menuselect_default
$(SED) -i -r -e '/name="$(strip $(1))"/{N;N;N;N;N;N;s,(<defaultenabled>)(no|yes)(</defaultenabled>),\1$(strip $(2))\3,'} $(strip $(3));
endef

# $(1): module name
# $(2): value (yes or no)
define $(pkg)_set_module_menuselect_default
$(SED) -i -r -e '/^\/[*]{3}[ \t]+MODULEINFO/{N;N;N;N;N;N;s,(<defaultenabled>)(no|yes)(</defaultenabled>),\1$(strip $(2))\3,'} $(foreach cat,$(ASTERISK_CATEGORY_DIRS),$(cat)/$(strip $(1)).c) 2>/dev/null || true;
endef

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_DIR)/addons/mp3/mpg123.h: $($(PKG)_DIR)/.unpacked
	(cd $(ASTERISK_DIR); ./contrib/scripts/get_mp3_source.sh)
	touch -c $@

$($(PKG)_DIR)/.configured: | $($(PKG)_DIR)/addons/mp3/mpg123.h

$(pkg)-defaults-adjusted: $($(PKG)_DIR)/.defaults_adjusted
$($(PKG)_DIR)/.defaults_adjusted: $($(PKG)_DIR)/.unpacked
# add <defaultenabled> xml-elements to the asterisk .xml and source files menuselect is generated from
	@(cd $(ASTERISK_DIR); \
		$(SED) -i -r -e 's,(<member name="EMBED_[^>]*>),\1<defaultenabled>no</defaultenabled>,' ./build_tools/embed_modules.xml; \
		find \
			$(ASTERISK_CATEGORY_DIRS) \
			-maxdepth 1 \
			-regextype posix-extended -regex "[^/]*/($(strip $(ASTERISK_CATEGORY_PREFIXES)))_.*[.]c" \
			-exec \
				$(SED) -i -r -f $(abspath $(ASTERISK_MAKE_DIR)/moduleinfo-add-default-enabled-if-missing.sed) \{\} \+; \
	)
# sync options selected in freetz menuconfig with defaults in asterisk's menuselect
	@(cd $(ASTERISK_DIR); \
		$(call asterisk_set_option_menuselect_default,LOW_MEMORY,$(if $(FREETZ_PACKAGE_ASTERISK_LOWMEMORY),yes,no),./build_tools/cflags.xml) \
		$(call asterisk_set_option_menuselect_default,DEBUG_THREADS,$(if $(FREETZ_PACKAGE_ASTERISK_DEBUG),yes,no),./build_tools/cflags.xml) \
		$(call asterisk_set_option_menuselect_default,DONT_OPTIMIZE,$(if $(FREETZ_PACKAGE_ASTERISK_DEBUG),yes,no),./build_tools/cflags.xml) \
		\
		$(foreach cat,$(ASTERISK_EMBED_CATEGORIES),$(call asterisk_set_option_menuselect_default,EMBED_$(cat),$(if $(FREETZ_PACKAGE_ASTERISK_EMBED_MODULES),yes,no),./build_tools/embed_modules.xml)) \
		\
		$(call asterisk_set_option_menuselect_default,STATIC_BUILD,$(if $(FREETZ_PACKAGE_ASTERISK_STATIC),yes,no),./build_tools/cflags.xml) \
		$(call asterisk_set_option_menuselect_default,LOADABLE_MODULES,$(if $(FREETZ_PACKAGE_ASTERISK_STATIC),no,yes),./build_tools/cflags.xml) \
	)
ifneq ($(findstring $(pkg)-generate,$(MAKECMDGOALS)),$(pkg)-generate)
# in "embed modules"-case build only modules selected for embedding
ifeq ($(strip $(FREETZ_PACKAGE_ASTERISK_EMBED_MODULES)),y)
	@(cd $(ASTERISK_DIR); \
		$(foreach module,$(ASTERISK_MODULES_ALL),$(call asterisk_set_module_menuselect_default,$(module),$(if $(FREETZ_PACKAGE_ASTERISK_$(call TOUPPER_NAME,$(module))),yes,no))) \
	)
endif
endif
	touch $@

$($(PKG)_DIR)/menuselect/menuselect: $($(PKG)_DIR)/.defaults_adjusted
	(cd $(ASTERISK_DIR)/menuselect && USE_GTK2=no ./configure)
	$(SUBMAKE1) -C $(ASTERISK_DIR)/menuselect

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.defaults_adjusted $($(PKG)_DIR)/menuselect/menuselect

$($(PKG)_DIR)/menuselect-tree: $($(PKG)_DIR)/.configured
	$(SUBMAKE1) $(ASTERISK_MAKE_OPTIONS) menuselect-tree

$($(PKG)_DIR)/.compiled: $($(PKG)_DIR)/.configured
	$(SUBMAKE1) $(ASTERISK_MAKE_OPTIONS)
	touch $@

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.compiled
	$(SUBMAKE1) $(ASTERISK_MAKE_OPTIONS) \
		DESTDIR="$(ASTERISK_INSTALL_DIR_ABSOLUTE)" \
		install samples
# 3rd-party modules may redefine PACKAGE_* variables, wrap asterisk variables with #ifndef to avoid warnings
	$(SED) -i -r -e 's,(\#define (PACKAGE_[A-Za-z0-9]*)[ \t].*),\#ifndef \2\n\1\n\#endif,g' $(ASTERISK_INSTALL_DIR)/usr/include/asterisk/autoconfig.h
	touch $@

$($(PKG)_BINARY_BUILD_DIR) $(if $(FREETZ_PACKAGE_ASTERISK_EMBED_MODULES),,$($(PKG)_MODULES_BUILD_DIR)): $($(PKG)_DIR)/.installed

$($(PKG)_BINARY_TARGET_DIR): $($(PKG)_BINARY_BUILD_DIR)
	$(if $(FREETZ_PACKAGE_ASTERISK_DEBUG),$(INSTALL_FILE),$(INSTALL_BINARY_STRIP))

ifneq ($(strip $(FREETZ_PACKAGE_ASTERISK_EMBED_MODULES)),y)
$($(PKG)_MODULES_TARGET_DIR): $($(PKG)_DEST_DIR)$($(PKG)_MODULES_DIR)/%: $($(PKG)_INSTALL_DIR)$($(PKG)_MODULES_DIR)/%
	$(if $(FREETZ_PACKAGE_ASTERISK_DEBUG),$(INSTALL_FILE),$(INSTALL_BINARY_STRIP))
endif

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARY_TARGET_DIR) $(if $(FREETZ_PACKAGE_ASTERISK_EMBED_MODULES),,$($(PKG)_MODULES_TARGET_DIR))

$(pkg)-clean:
	-$(SUBMAKE1) $(ASTERISK_MAKE_OPTIONS) distclean
	$(RM) $(ASTERISK_DIR)/{.defaults_adjusted,.configured,.compiled,.installed}

$(pkg)-uninstall:
	$(RM) -r \
		$(ASTERISK_BINARY_TARGET_DIR) \
		$(ASTERISK_DEST_DIR)$(ASTERISK_MODULES_DIR)

$(pkg)-generate: | $($(PKG)_DIR)/menuselect-tree
	@echo -n "Generating menuconfig file... "
	@( \
		$(ASTERISK_MAKE_DIR)/generate-menuconfig.py $(ASTERISK_DIR)/menuselect-tree > $(ASTERISK_MAKE_DIR)/Config.in.generated \
	) && echo "done"
	@echo -n "Generating modules list... "
	@( \
		echo '$$(PKG)_MODULES_ALL := \' > $(ASTERISK_MAKE_DIR)/asterisk-modules.mk.in \
		&& cat $(ASTERISK_MAKE_DIR)/Config.in.generated \
		| grep 'config FREETZ_PACKAGE_ASTERISK' \
		| grep -v 'FREETZ_PACKAGE_ASTERISK_WITH' \
		| sort -u \
		| sed -r -e 's,[ \t]*config FREETZ_PACKAGE_ASTERISK_([0-9A-Za-z_]*).*,\1 \\,g' \
		| tr '[:upper:]' '[:lower:]' \
		| sed -r -e 's,(res_xmpp) \\,\1,g' \
		>> $(ASTERISK_MAKE_DIR)/asterisk-modules.mk.in \
	) && echo "done"

$(PKG_FINISH)
