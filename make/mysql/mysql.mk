$(call PKG_INIT_BIN, 6.0.11-alpha)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://mirror.cogentco.com/pub/$(pkg)/MySQL-6.0/
$(PKG)_HASH:=94164a295b7f020edd7b95ae236e196b69e3c27e782a864ec2c6f5f9cec1ecac

$(PKG)_BINARY_BUILD_DIR := $($(PKG)_DIR)/sql/$(pkg)d
$(PKG)_BINARY_TARGET_DIR := $($(PKG)_DEST_DIR)/usr/bin/$(pkg)d

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MYSQL_mysqld
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MYSQL_mysql
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MYSQL_setup

$(PKG)_CONDITIONAL_PATCHES+=$(FREETZ_TARGET_ARCH)
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_ARCH

$(PKG)_DEPENDS_ON += ncurses $(STDCXXLIB) zlib openssl
$(PKG)_REBUILD_SUBOPTS += FREETZ_STDCXXLIB

$(PKG)_CONFIGURE_OPTIONS += --with-big-tables=no
$(PKG)_CONFIGURE_OPTIONS += --with-system-type=no
$(PKG)_CONFIGURE_OPTIONS += --with-machine-type=no
$(PKG)_CONFIGURE_OPTIONS += --disable-option-checking
$(PKG)_CONFIGURE_OPTIONS += --with-debug=no
$(PKG)_CONFIGURE_OPTIONS += --without-ndb-debug
$(PKG)_CONFIGURE_OPTIONS += --with-tcp-port=54234
$(PKG)_CONFIGURE_OPTIONS += --with-error-inject=no
$(PKG)_CONFIGURE_OPTIONS += --disable-largefile
$(PKG)_CONFIGURE_OPTIONS += --without-docs \
			    --without-man \
			    --without-bench \
			    --disable-assembler \
			    --without-mysqlmanager \
			    --without-raid \
			    --without-libwrap \
			    --without-pstack \
			    --with-low-memory \
			    --without-embedded-server \
			    --without-query-cache \
			    --without-mysqlfs \
			    --without-vio \
			    --with-readline \
			    --with-named-thread-libs=-lpthread \
			    --enable-static \
			    --enable-shared \
			    --enable-thread-safe-client \
			    --with-pthread \
			    --with-server

$(PKG)_CATEGORY:=Unstable

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(MYSQL_DIR) \
		CXXFLAGS="$(TARGET_CFLAGS) -fPIC"

$($(PKG)_BINARY_TARGET_DIR): $($(PKG)_BINARY_BUILD_DIR)
	mkdir -p $(MYSQL_DEST_DIR)/usr/share/mysql/
	if [ "$(FREETZ_PACKAGE_MYSQL_mysqld)" == "y" ]; then \
		$(INSTALL_BINARY_STRIP) \
		cp -ar $(MYSQL_DIR)/sql/share/english/ $(MYSQL_DEST_DIR)/usr/share/mysql/ ;\
	fi
	# setup
	if [ "$(FREETZ_PACKAGE_MYSQL_setup)" == "y" ]; then \
		tar cf $(MYSQL_DEST_DIR)/usr/share/mysql/mysql.tbz -C $(MYSQL_DIR)/win/data/ mysql/ ;\
	fi
	# mysql
	if [ "$(FREETZ_PACKAGE_MYSQL_mysql)" == "y" ]; then \
		cp -ar $(MYSQL_DIR)/client/.libs/mysql $(MYSQL_DEST_DIR)/usr/bin/ ;\
		mkdir -p $(MYSQL_DEST_DIR)$(FREETZ_LIBRARY_DIR)/ ;\
		cp -ar $(MYSQL_DIR)/libmysql/.libs/libmysqlclient.so* $(MYSQL_DEST_DIR)$(FREETZ_LIBRARY_DIR)/ ;\
	fi

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARY_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(MYSQL_DIR) clean
	$(RM) $(MYSQL_DIR)/.configured

$(pkg)-uninstall:
	$(RM) -r $(MYSQL_BINARY_TARGET_DIR) $(MYSQL_DEST_DIR)

$(PKG_FINISH)
