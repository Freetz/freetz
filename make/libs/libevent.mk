# released under the GNU public license v2
#
LIBEVENT_VERSION:=1.3b
LIBEVENT_SOURCE:=libevent-$(LIBEVENT_VERSION).tar.gz
LIBEVENT_SITE:=http://www.monkey.org/~provos
LIBEVENT_DIR:=$(SOURCE_DIR)/libevent-$(LIBEVENT_VERSION)
LIBEVENT_MAKE_DIR:=$(MAKE_DIR)/libs

$(DL_DIR)/$(LIBEVENT_SOURCE):
	wget -P $(DL_DIR) $(LIBEVENT_SITE)/$(LIBEVENT_SOURCE)

$(LIBEVENT_DIR)/.unpacked: $(DL_DIR)/$(LIBEVENT_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(LIBEVENT_SOURCE)
	for i in $(LIBEVENT_MAKE_DIR)/patches/*.libevent.patch; do \
		patch -d $(LIBEVENT_DIR) -p0 < $$i; \
	done
	touch $@

$(LIBEVENT_DIR)/.configured: $(LIBEVENT_DIR)/.unpacked
	( cd $(LIBEVENT_DIR); rm -f config.status; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) $(CFLAGS_LARGEFILE)" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-XCClinker -static-libgcc -L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		./configure \
		  --target=$(GNU_TARGET_NAME) \
		  --host=$(GNU_TARGET_NAME) \
		  --build=$(GNU_HOST_NAME) \
		  --program-prefix="" \
		  --program-suffix="" \
		  --prefix=/usr \
		  --exec-prefix=/usr \
		  --bindir=/usr/bin \
		  --datadir=/usr/share \
		  --includedir=/usr/include \
		  --infodir=/usr/share/info \
		  --libdir=/usr/lib \
		  --libexecdir=/usr/lib \
		  --localstatedir=/var \
		  --mandir=/usr/share/man \
		  --sbindir=/usr/sbin \
		  --sysconfdir=/etc \
		  $(DISABLE_LARGEFILE) \
		  $(DISABLE_NLS) \
		  --enable-shared \
		  --disable-static \
	);
	touch $@

$(LIBEVENT_DIR)/.compiled: $(LIBEVENT_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(LIBEVENT_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) $(CFLAGS_LARGEFILE)" \
		libevent.la
	touch $@

$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libevent.so: $(LIBEVENT_DIR)/.compiled
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(LIBEVENT_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install-strip
	touch -c $@

ifeq ($(strip $(DS_EXTERNAL_COMPILER)),y)
libevent libevent-precompiled:
	@echo 'External compiler used. Trying to copy libevent from external Toolchain...'
	cp -a $(TARGET_MAKE_PATH)/../usr/lib/libevent*.so* root/usr/lib/
else
libevent: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libevent.so
libevent-precompiled: libevent
	$(TARGET_STRIP) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libevent*.so*
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libevent*.so* root/usr/lib/
endif

libevent-source: $(LIBEVENT_DIR)/.unpacked

libevent-clean:
	-$(MAKE) -C $(LIBEVENT_DIR) clean

libevent-dirclean:
	rm -rf $(LIBEVENT_DIR)
