$(call PKG_INIT_BIN, 2.7.3)
$(PKG)_SOURCE:=Python-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=c57477edd6d18bd9eeca2f21add73919
$(PKG)_SITE:=http://www.python.org/ftp/python/$($(PKG)_VERSION)

$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/Python-$($(PKG)_VERSION)

$(PKG)_LOCAL_INSTALL_DIR:=$($(PKG)_DIR)/_install

$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/python2.7_bin
$(PKG)_LIB_PYTHON_TARGET_DIR:=$($(PKG)_TARGET_LIBDIR)/libpython2.7.so.1.0

$(PKG)_BUILD_PREREQ += zip

$(PKG)_HOST_DEPENDS_ON := python-host python-setuptools python-distutilscross
# libffi is a compile-time dependency only
$(PKG)_DEPENDS_ON := libffi

$(PKG)_COMPRESS_PYC :=

ifeq ($(strip $(FREETZ_PACKAGE_PYTHON_COMPRESS_PYC)),y)
$(PKG)_COMPRESS_PYC += zip -9myR ../python27.zip . "*.pyc";
$(PKG)_COMPRESS_PYC += $(RM) -r bsddb compiler ctypes curses distutils email encodings;
$(PKG)_COMPRESS_PYC += $(RM) -r hotshot importlib json logging multiprocessing;
$(PKG)_COMPRESS_PYC += $(RM) -r plat-linux2 pydoc_data unittest;
endif

$(PKG)_REMOVE_MODS :=

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_AUDIODEV)),y)
$(PKG)_REMOVE_MODS += lib-dynload/linuxaudiodev.so
$(PKG)_REMOVE_MODS += lib-dynload/ossaudiodev.so
endif

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_AUDIOOP)),y)
$(PKG)_REMOVE_MODS += lib-dynload/audioop.so
endif

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_BISECT)),y)
$(PKG)_REMOVE_MODS += lib-dynload/_bisect.so
$(PKG)_REMOVE_MODS += bisect.py*
endif

ifeq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_BSDDB)),y)
$(PKG)_DEPENDS_ON += db
else
$(PKG)_REMOVE_MODS += bsddb
$(PKG)_REMOVE_MODS += dbhash.py*
$(PKG)_REMOVE_MODS += lib-dynload/dbm.so
$(PKG)_REMOVE_MODS += lib-dynload/_bsddb.so
endif

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_CMATH)),y)
$(PKG)_REMOVE_MODS += lib-dynload/cmath.so
endif

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_COLLECTIONS)),y)
$(PKG)_REMOVE_MODS += lib-dynload/_collections.so
$(PKG)_REMOVE_MODS += _acoll.py*
$(PKG)_REMOVE_MODS += collections.py*
endif

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_CPROFILE)),y)
$(PKG)_REMOVE_MODS += lib-dynload/_lsprof.so
$(PKG)_REMOVE_MODS += cProfile.py*
endif

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_CSV)),y)
$(PKG)_REMOVE_MODS += lib-dynload/_csv.so
$(PKG)_REMOVE_MODS += csv.py*
endif

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_CRYPT)),y)
$(PKG)_REMOVE_MODS += lib-dynload/crypt.so
endif

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_CTYPES)),y)
$(PKG)_REMOVE_MODS += lib-dynload/_ctypes.so
$(PKG)_REMOVE_MODS += lib-dynload/_ctypes_test.so
$(PKG)_REMOVE_MODS += ctypes
endif

ifeq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_CURSES)),y)
$(PKG)_DEPENDS_ON += ncurses
else
$(PKG)_REMOVE_MODS += curses
$(PKG)_REMOVE_MODS += lib-dynload/_curses.so
$(PKG)_REMOVE_MODS += lib-dynload/_curses_panel.so
endif

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_DATETIME)),y)
$(PKG)_REMOVE_MODS += lib-dynload/datetime.so
endif

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_EASTERN_CODECS)),y)
$(PKG)_REMOVE_MODS += lib-dynload/_codecs_*.so
$(PKG)_REMOVE_MODS += lib-dynload/_multibytecodec.so
$(PKG)_REMOVE_MODS += encodings/big5.py*
$(PKG)_REMOVE_MODS += encodings/big5hkscs.py*
$(PKG)_REMOVE_MODS += encodings/cp932.py*
$(PKG)_REMOVE_MODS += encodings/cp949.py*
$(PKG)_REMOVE_MODS += encodings/cp950.py*
$(PKG)_REMOVE_MODS += encodings/euc_jis_2004.py*
$(PKG)_REMOVE_MODS += encodings/euc_jisx0213.py*
$(PKG)_REMOVE_MODS += encodings/euc_jp.py*
$(PKG)_REMOVE_MODS += encodings/euc_kr.py*
$(PKG)_REMOVE_MODS += encodings/gb18030.py*
$(PKG)_REMOVE_MODS += encodings/gb2312.py*
$(PKG)_REMOVE_MODS += encodings/gbk.py*
$(PKG)_REMOVE_MODS += encodings/hz.py*
$(PKG)_REMOVE_MODS += encodings/iso2022_jp*.py*
$(PKG)_REMOVE_MODS += encodings/iso2022_kr*.py*
$(PKG)_REMOVE_MODS += encodings/johab.py*
$(PKG)_REMOVE_MODS += encodings/shift_jis*.py*
endif

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_ELEMENTTREE)),y)
$(PKG)_REMOVE_MODS += lib-dynload/_elementtree.so
$(PKG)_REMOVE_MODS += xml/etree/cElementTree.py*
endif

ifeq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_EXPAT)),y)
$(PKG)_DEPENDS_ON += expat
$(PKG)_CONFIGURE_OPTIONS += --with-system-expat
else
$(PKG)_REMOVE_MODS += lib-dynload/pyexpat.so
$(PKG)_REMOVE_MODS += xml/dom/expatbuilder.py*
$(PKG)_REMOVE_MODS += xml/sax/expatreader.py*
$(PKG)_REMOVE_MODS += xml/parsers
endif

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_FCNTL)),y)
$(PKG)_REMOVE_MODS += lib-dynload/fcntl.so
endif

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_FUNCTOOLS)),y)
$(PKG)_REMOVE_MODS += lib-dynload/_functools.so
$(PKG)_REMOVE_MODS += functools.py*
endif

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_GRP)),y)
$(PKG)_REMOVE_MODS += lib-dynload/grp.so
endif

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_HASHLIB)),y)
$(PKG)_REMOVE_MODS += lib-dynload/_hashlib.so
$(PKG)_REMOVE_MODS += hashlib.py
endif

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_HOTSHOT)),y)
$(PKG)_REMOVE_MODS += lib-dynload/_hotshot.so
$(PKG)_REMOVE_MODS += hotshot
endif

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_IO)),y)
$(PKG)_REMOVE_MODS += lib-dynload/_io.so
$(PKG)_REMOVE_MODS += _pyio.py*
$(PKG)_REMOVE_MODS += io.py*
endif

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_JSON)),y)
$(PKG)_REMOVE_MODS += lib-dynload/_json.so
$(PKG)_REMOVE_MODS += json
endif

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_MULTIPROCESSING)),y)
$(PKG)_REMOVE_MODS += lib-dynload/_multiprocessing.so
$(PKG)_REMOVE_MODS += multiprocessing
endif

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_MMAP)),y)
$(PKG)_REMOVE_MODS += lib-dynload/mmap.so
endif

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_OPERATOR)),y)
$(PKG)_REMOVE_MODS += lib-dynload/operator.so
endif

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_RANDOM)),y)
$(PKG)_REMOVE_MODS += lib-dynload/_random.so
$(PKG)_REMOVE_MODS += random.py*
endif

ifeq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_READLINE)),y)
$(PKG)_DEPENDS_ON += readline
else
$(PKG)_REMOVE_MODS += lib-dynload/readline.so
$(PKG)_REMOVE_MODS += rlcompleter.py*
endif

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_RESOURCE)),y)
$(PKG)_REMOVE_MODS += lib-dynload/resource.so
endif

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_SOCKET)),y)
$(PKG)_REMOVE_MODS += lib-dynload/_socket.so
$(PKG)_REMOVE_MODS += socket.py*
$(PKG)_REMOVE_MODS += SocketServer.py*
endif

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_SPWD)),y)
$(PKG)_REMOVE_MODS += lib-dynload/spwd.so
endif

ifeq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_SSL)),y)
$(PKG)_DEPENDS_ON += openssl
else
$(PKG)_REMOVE_MODS += lib-dynload/_ssl.so
endif

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_STRUCT)),y)
$(PKG)_REMOVE_MODS += lib-dynload/_struct.so
$(PKG)_REMOVE_MODS += struct.py*
endif

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_SYSLOG)),y)
$(PKG)_REMOVE_MODS += lib-dynload/syslog.so
endif

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_TERMIOS)),y)
$(PKG)_REMOVE_MODS += lib-dynload/termios.so
endif

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_TEST)),y)
$(PKG)_REMOVE_MODS += lib-dynload/ctypes_test.so
$(PKG)_REMOVE_MODS += lib-dynload/_testcapi.so
$(PKG)_REMOVE_MODS += test
$(PKG)_REMOVE_MODS += unittest
$(PKG)_REMOVE_MODS += bsddb/test
$(PKG)_REMOVE_MODS += ctypes/test
$(PKG)_REMOVE_MODS += distutils/test
$(PKG)_REMOVE_MODS += email/test
$(PKG)_REMOVE_MODS += json/test
$(PKG)_REMOVE_MODS += sqlite3/test
endif

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_TIME)),y)
$(PKG)_REMOVE_MODS += lib-dynload/time.so
endif

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_UNICODEDATA)),y)
$(PKG)_REMOVE_MODS += lib-dynload/unicodedata.so
endif

ifeq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_ZLIB)),y)
$(PKG)_DEPENDS_ON += zlib
else
$(PKG)_REMOVE_MODS += lib-dynload/zlib.so
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON_COMPRESS_PYC
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON_MOD_BSDDB
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON_MOD_CURSES
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON_MOD_SSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON_MOD_READLINE
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON_MOD_ZLIB
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG)_CONFIGURE_ENV += ac_cv_have_chflags=no
$(PKG)_CONFIGURE_ENV += ac_cv_have_lchflags=no
$(PKG)_CONFIGURE_ENV += ac_cv_py_format_size_t=no
$(PKG)_CONFIGURE_ENV += ac_cv_have_long_long_format=yes
$(PKG)_CONFIGURE_ENV += ac_cv_buggy_getaddrinfo=no
$(PKG)_CONFIGURE_ENV += OPT="-fno-inline"

# use local config.cache to avoid conflicts with other packages
# TODO: check if this is still necessary
$(PKG)_CONFIGURE_OPTIONS += --cache-file=config.cache

$(PKG)_CONFIGURE_OPTIONS += --with-system-ffi
$(PKG)_CONFIGURE_OPTIONS += --with-threads
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_PYTHON_STATIC),--disable-shared,--enable-shared)

# remove local copy of libffi, we use system one
$(PKG)_CONFIGURE_PRE_CMDS += $(RM) -r Modules/_ctypes/libffi*;
# remove local copy of zlib, we use system one
$(PKG)_CONFIGURE_PRE_CMDS += $(RM) -r Modules/zlib;

# The python executable needs to stay in the root of the builddir
# since its location is used to compute the path of the config files.
$(PKG)_CONFIGURE_PRE_CMDS += cp $(HOST_TOOLS_DIR)/usr/bin/pgen hostpgen;
$(PKG)_CONFIGURE_PRE_CMDS += cp $(HOST_TOOLS_DIR)/usr/bin/python2.7 hostpython;

$(PKG)_MAKE_OPTIONS := CROSS_TOOLCHAIN_SYSROOT="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_MAKE_OPTIONS += HOSTPYTHON_COMPILE="$(abspath $(HOST_TOOLS_DIR)/usr/bin/python)"
$(PKG)_MAKE_OPTIONS += HOSTPYTHON="$(abspath $($(PKG)_DIR)/hostpython)"
$(PKG)_MAKE_OPTIONS += HOSTPGEN="$(abspath $($(PKG)_DIR)/hostpgen)"
$(PKG)_MAKE_OPTIONS += AR="$(TARGET_AR)"

ifneq ($(strip $(DL_DIR)/$(PYTHON_SOURCE)),$(strip $(DL_DIR)/$(PYTHON_HOST_SOURCE)))
$(PKG_SOURCE_DOWNLOAD)
endif
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_DIR)/.compiled: $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(PYTHON_DIR) \
		$(PYTHON_MAKE_OPTIONS) \
		all
	touch $@

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.compiled
	$(SUBMAKE) -C $(PYTHON_DIR) \
		$(PYTHON_MAKE_OPTIONS) \
		DESTDIR="$(FREETZ_BASE_DIR)/$(PYTHON_LOCAL_INSTALL_DIR)" \
		install
	(cd $(FREETZ_BASE_DIR)/$(PYTHON_LOCAL_INSTALL_DIR); \
		chmod -R u+w usr; \
		$(RM) -r \
			usr/bin/2to3 \
			usr/bin/idle \
			usr/bin/pydoc \
			usr/bin/python*-config \
			usr/bin/smtpd.py \
			\
			usr/lib/libpython2.7.a \
			\
			usr/lib/python2.7/lib2to3 \
			usr/lib/python2.7/idlelib \
			usr/lib/python2.7/lib-old \
			usr/lib/python2.7/lib-tk \
			usr/lib/python2.7/plat-linux3 \
			usr/lib/python2.7/pdb.doc \
			\
			usr/lib/python2.7/sqlite3 \
			usr/lib/python2.7/lib-dynload/_sqlite3.so \
			\
			usr/lib/python2.7/wsgiref \
			usr/lib/python2.7/wsgiref.egg-info \
			\
			usr/lib/python2.7/lib-dynload/future_builtins.so \
			\
			usr/lib/python2.7/LICENSE.txt \
			usr/lib/python2.7/site-packages/README \
			\
			usr/lib/python2.7/config/* \
			\
			usr/lib/pkgconfig \
			\
			usr/share; \
		\
		touch usr/lib/python2.7/config/Makefile; \
		\
		find usr/include/python2.7/ -name "*.h" \! -name "pyconfig.h" \! -name "Python.h" -delete; \
		find usr/lib/python2.7/ \( -name "*.py" -o -name "*.pyo" \) -delete; \
		\
		$(TARGET_STRIP) \
			usr/bin/python2.7 \
			$(if $(FREETZ_PACKAGE_PYTHON_STATIC),,usr/lib/libpython2.7.so.1.0) \
			usr/lib/python2.7/lib-dynload/*.so; \
		\
		mv usr/bin/python2.7 usr/bin/python2.7_bin; \
	)
	(cd $(FREETZ_BASE_DIR)/$(PYTHON_LOCAL_INSTALL_DIR)/usr/lib/python2.7; \
		$(RM) -r $(PYTHON_REMOVE_MODS); \
		$(PYTHON_COMPRESS_PYC) \
		find . -type d -depth -empty -delete; \
	)
	touch $@

$(PYTHON_TARGET_BINARY): $($(PKG)_DIR)/.installed
	tar -c -C $(PYTHON_LOCAL_INSTALL_DIR) --exclude='libpython2.7.so*' . | tar -x -C $(PYTHON_DEST_DIR)
	touch -c $@

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_STATIC)),y)
$($(PKG)_LIB_PYTHON_TARGET_DIR): $($(PKG)_DIR)/.installed
	mkdir -p $(dir $@); \
	cp -a $(PYTHON_LOCAL_INSTALL_DIR)/usr/lib/libpython2.7.so* $(dir $@); \
	touch -c $@
endif

$(pkg):

$(pkg)-precompiled: $(PYTHON_TARGET_BINARY) $(if $(FREETZ_PACKAGE_PYTHON_STATIC),,$(PYTHON_LIB_PYTHON_TARGET_DIR))

$(pkg)-clean:
	-$(SUBMAKE) -C $(PYTHON_DIR) clean
	$(RM) $(PYTHON_FREETZ_CONFIG_FILE)
	$(RM) $(PYTHON_DIR)/.configured $(PYTHON_DIR)/.compiled $(PYTHON_DIR)/.installed
	$(RM) -r $(PYTHON_LOCAL_INSTALL_DIR)

$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON_TARGET_BINARY) \
		$(PYTHON_TARGET_LIBDIR)/libpython2.7.so* \
		$(PYTHON_DEST_DIR)/usr/bin/python \
		$(PYTHON_DEST_DIR)/usr/bin/python2 \
		$(PYTHON_DEST_DIR)/usr/lib/python2.7 \
		$(PYTHON_DEST_DIR)/usr/lib/python27.zip \
		$(PYTHON_DEST_DIR)/usr/include/python2.7

$(PKG_FINISH)
