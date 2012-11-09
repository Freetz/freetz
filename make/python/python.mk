$(call PKG_INIT_BIN, 2.7.3)
$(PKG)_SOURCE:=Python-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://www.python.org/ftp/python/$($(PKG)_VERSION)
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/Python-$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/python
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/python2.7_bin
$(PKG)_SOURCE_MD5:=c57477edd6d18bd9eeca2f21add73919

ifeq ($(strip $(FREETZ_LIB_libpython)),y)
$(PKG)_LIB_PYTHON_BINARY:=$($(PKG)_DIR)/libpython2.7.so.1.0
$(PKG)_LIB_PYTHON_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpython2.7.so.1.0
$(PKG)_LIB_PYTHON_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/lib/libpython2.7.so.1.0
else
$(PKG)_LIB_PYTHON_BINARY:=
$(PKG)_LIB_PYTHON_STAGING_BINARY:=
$(PKG)_LIB_PYTHON_TARGET_BINARY:=
endif

$(PKG)_COMPRESS_PYC := 

ifeq ($(strip $(FREETZ_PACKAGE_PYTHON_COMPRESS_PYC)),y)
$(PKG)_COMPRESS_PYC += zip -9myR ../python27.zip . "*.pyc";
$(PKG)_COMPRESS_PYC += rm -rf bsddb compiler ctypes curses distutils email encodings;
$(PKG)_COMPRESS_PYC += rm -rf hotshot importlib json logging multiprocessing;
$(PKG)_COMPRESS_PYC += rm -rf plat-linux2 pydoc_data unittest;
endif

$(PKG)_DEPENDS_ON :=
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

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_EXPAT)),y)
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

# Readline module segfaults :-(
#  -> remove uncoditionally
$(PKG)_REMOVE_MODS += lib-dynload/readline.so
$(PKG)_REMOVE_MODS += rlcompleter.py*
#ifeq ($(strip $(FREETZ_PACKAGE_PYTHON_MOD_READLINE)),y)
#$(PKG)_DEPENDS_ON += readline
#else
#$(PKG)_REMOVE_MODS += lib-dynload/readline.so
#$(PKG)_REMOVE_MODS += rlcompleter.py*
#endif

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
#$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON_MOD_READLINE
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON_MOD_ZLIB

HOST_TOOLCHAIN_DIR:=$(FREETZ_BASE_DIR)/$(TOOLCHAIN_DIR)/host

$(PKG)_CONFIGURE_DEFOPTS := y

$(PKG)_CONFIGURE_ENV += CPPFLAGS="-I. -IInclude -I$(TARGET_TOOLCHAIN_STAGING_DIR)/include -I$(TARGET_TOOLCHAIN_STAGING_DIR)/include/openssl"
$(PKG)_CONFIGURE_ENV += LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib"
$(PKG)_CONFIGURE_ENV += ac_cv_have_chflags=no
$(PKG)_CONFIGURE_ENV += ac_cv_have_lchflags=no
$(PKG)_CONFIGURE_ENV += ac_cv_py_format_size_t=no
$(PKG)_CONFIGURE_ENV += ac_cv_have_long_long_format=yes
$(PKG)_CONFIGURE_ENV += ac_cv_buggy_getaddrinfo=no
$(PKG)_CONFIGURE_ENV += DYNLOADFILE="dynload_shlib.o"
$(PKG)_CONFIGURE_ENV += OPT="$(TARGET_CFLAGS)"
$(PKG)_CONFIGURE_ENV += LIBFFI_INCLUDEDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)/include"

$(PKG)_CONFIGURE_OPTIONS += --prefix=/usr
$(PKG)_CONFIGURE_OPTIONS += --with-libs="-lutil"
$(PKG)_CONFIGURE_OPTIONS += --with-threads
$(PKG)_CONFIGURE_OPTIONS += --cache-file=config.cache
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_PYTHON_STATIC),--disable-shared,--enable-shared)

$(PKG)_CONFIGURE_PRE_CMDS += (cd $(FREETZ_BASE_DIR)/$(PYTHON_DIR); autoreconf --force --install || exit 0);

$(PKG)_MAKE_OPTIONS := \
	$(PYTHON_CONFIGURE_ENV) \
	CROSS_COMPILE=yes \
	CFLAGS="$(TARGET_CFLAGS) -fno-inline" \
	LD="$(TARGET_CC)" \
	LDSHARED="$(TARGET_CC) -shared" \
	HOSTPYTHON=$(HOST_TOOLCHAIN_DIR)/usr/bin/python \
	HOSTPGEN=$(HOST_TOOLCHAIN_DIR)/usr/bin/pgen

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	rm -fr $(FREETZ_BASE_DIR)/$(PYTHON_DIR)/Modules/_ctypes/libffi*
	rm -fr $(FREETZ_BASE_DIR)/$(PYTHON_DIR)/Modules/zlib
	sed -i "/ HAVE_DLOPEN / a#define HAVE_DLOPEN 1" $(FREETZ_BASE_DIR)/$(PYTHON_DIR)/pyconfig.h
	sed -i "/# XXX Omitted modules: / a\ \ \ \ \ \ \ \ lib_dirs += ['$(TARGET_TOOLCHAIN_STAGING_DIR)/lib']" $(FREETZ_BASE_DIR)/$(PYTHON_DIR)/setup.py
	sed -i "/# XXX Omitted modules: / a\ \ \ \ \ \ \ \ inc_dirs += ['$(TARGET_TOOLCHAIN_STAGING_DIR)/include']" $(FREETZ_BASE_DIR)/$(PYTHON_DIR)/setup.py
	$(SUBMAKE) -C $(PYTHON_DIR) all \
		$(PYTHON_MAKE_OPTIONS)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(PYTHON_DIR) install \
		$(PYTHON_MAKE_OPTIONS) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)"
	$(SUBMAKE) -C $(PYTHON_DIR) install \
		$(PYTHON_MAKE_OPTIONS) \
		DESTDIR="$(FREETZ_BASE_DIR)/$(PYTHON_DEST_DIR)"
	$(INSTALL_BINARY_STRIP)
	(cd $(FREETZ_BASE_DIR)/$(PYTHON_DEST_DIR)/usr; \
		rm -rf lib/libpython2.7.a share/; \
		find include/python2.7/ -name "*.h" \! -name "pyconfig.h" \
			\! -name "Python.h" -delete; \
		cd $(FREETZ_BASE_DIR)/$(PYTHON_DEST_DIR)/usr/bin; \
		mv python_wrapper python2.7; \
		chmod 755 python2.7; \
		rm -rf 2to3 idle pydoc smtpd.py; \
		cd $(FREETZ_BASE_DIR)/$(PYTHON_DEST_DIR)/usr/lib/python2.7; \
		rm -rf idlelib lib2to3 lib-old lib-tk plat-linux3 pdb.doc; \
		rm -rf sqlite3 wsgiref wsgiref.egg-info xml; \
		rm -f lib-dynload/future_builtins.so lib-dynload/_sqlite3.so; \
		rm -rf $(PYTHON_REMOVE_MODS); \
		find -name "*.py" -delete; \
		find -name "*.pyo" -delete; \
		$(PYTHON_COMPRESS_PYC) \
		cd $(FREETZ_BASE_DIR)/$(PYTHON_DEST_DIR)/usr/lib/python2.7/lib-dynload; \
		$(TARGET_STRIP) *.so; \
		chmod 644 *.so; \
	)
	(cd $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin; \
		rm -rf 2to3 idle pydoc python python2.7 python-config smtpd.py; \
		cd $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib; \
		rm -rf python2.7; \
	)

$($(PKG)_LIB_PYTHON_BINARY):

$($(PKG)_LIB_PYTHON_STAGING_BINARY): $($(PKG)_LIB_PYTHON_BINARY)

$($(PKG)_LIB_PYTHON_TARGET_BINARY): $($(PKG)_LIB_PYTHON_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-test: $(PYTHON_BINARY)

$(pkg)-precompiled: $(PYTHON_TARGET_BINARY) \
		$(PYTHON_LIB_PYTHON_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(PYTHON_DIR) clean
	$(RM) $(PYTHON_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(PYTHON_TARGET_BINARY)
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/python
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/python2.7
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/2to3
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/idle
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/pydoc
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/smtpd.py
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/python2.7
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpython2.7.so*
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/python2.7
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/python2.7
	$(RM) $(PYTHON_DEST_DIR)/usr/bin/python
	$(RM) $(PYTHON_DEST_DIR)/usr/lib/libpython2.7.so*
	$(RM) $(PYTHON_DEST_DIR)/usr/lib/python2.7
	$(RM) $(PYTHON_DEST_DIR)/usr/lib/python27.zip

$(PKG_FINISH)
