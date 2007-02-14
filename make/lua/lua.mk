LUA_VERSION:=5.1.1
LUA_SOURCE:=lua-$(LUA_VERSION).tar.gz
LUA_SITE:=http://www.lua.org/ftp
LUA_DIR:=$(SOURCE_DIR)/lua-$(LUA_VERSION)
LUA_MAKE_DIR:=$(MAKE_DIR)/lua
LUA_TARGET_DIR:=$(PACKAGES_DIR)/lua-$(LUA_VERSION)/root/usr/bin
LUA_TARGET_BINARY:=lua
LUA_PKG_SOURCE:=lua-$(LUA_VERSION)-dsmod.tar.bz2

$(DL_DIR)/$(LUA_SOURCE):
	wget -P $(DL_DIR) $(LUA_SITE)/$(LUA_SOURCE)

$(DL_DIR)/$(LUA_PKG_SOURCE):
	@wget -P $(DL_DIR) $(LUA_PKG_SITE)/$(LUA_PKG_SOURCE)

$(LUA_DIR)/.unpacked: $(DL_DIR)/$(LUA_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(LUA_SOURCE)
	for i in $(LUA_MAKE_DIR)/patches/*.patch; do \
		patch -d $(LUA_DIR) -p0 < $$i; \
	done
	touch $@

$(LUA_DIR)/$(LUA_TARGET_BINARY): $(LUA_DIR)/.unpacked
	PATH="$(TARGET_PATH)" $(MAKE) -C $(LUA_DIR) \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
		MYCFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include $(TARGET_CFLAGS)" \
		AR="$(TARGET_CROSS)ar rcu" \
		RANLIB="$(TARGET_CROSS)ranlib" \
		MYLDFLAGS="-L$(TARGET_MAKE_PATH)/../usr/lib -static-libgcc" \
		INSTALL_ROOT=/usr \
		PKG_VERSION="$(LUA_VERSION)" \
		linux

$(PACKAGES_DIR)/.lua-$(LUA_VERSION): $(DL_DIR)/$(LUA_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(LUA_PKG_SOURCE)
	@touch $@

lua: $(PACKAGES_DIR)/.lua-$(LUA_VERSION)

lua-package: $(PACKAGES_DIR)/.lua-$(LUA_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) -cjf $(PACKAGES_BUILD_DIR)/$(LUA_PKG_SOURCE) lua-$(LUA_VERSION)


lua-precompiled: $(LUA_DIR)/$(LUA_TARGET_BINARY) lua
	$(TARGET_STRIP) $(LUA_DIR)/src/$(LUA_TARGET_BINARY)
	cp $(LUA_DIR)/src/$(LUA_TARGET_BINARY) $(LUA_TARGET_DIR)/

lua-source: $(LUA_DIR)/.unpacked $(PACKAGES_DIR)/.lua-$(LUA_VERSION)

lua-clean:
	-$(MAKE) -C $(LUA_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(LUA_PKG_SOURCE)

lua-dirclean:
	rm -rf $(LUA_DIR)
	rm -rf $(PACKAGES_DIR)/lua-$(LUA_VERSION)
	rm -f $(PACKAGES_DIR)/.lua-$(LUA_VERSION)

lua-list:
ifeq ($(strip $(DS_PACKAGE_LUA)),y)
	@echo "S40lua-$(LUA_VERSION)" >> .static
else
	@echo "S40lua-$(LUA_VERSION)" >> .dynamic
endif