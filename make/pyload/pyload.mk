PYLOAD_GIT_REPOSITORY:=https://github.com/pyload/pyload.git
$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_PYLOAD_VERSION_LATEST_GIT),$(call git-get-latest-revision,$(PYLOAD_GIT_REPOSITORY),stable),bea7fe466f))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SITE:=git@$($(PKG)_GIT_REPOSITORY)

$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/opt/pyLoad/pyLoadCore.py

$(PKG)_BUILD_PREREQ += git
$(PKG)_BUILD_PREREQ_HINT := Hint: on Debian-like systems this binary is provided by the git package (sudo apt-get install git)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYLOAD_VERSION_LATEST_TESTED
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYLOAD_VERSION_LATEST_GIT

define pyLoad/build/files
.build-prereq-checked
.unpacked
.configured
.exclude
endef

define pyLoad/unnecessary/files
.hgignore
.gitattributes
docs
icons
LICENSE
locale
module/cli
module/gui
module/lib/wsgiserver/LICENSE.txt
module/web/servers
pavement.py
pyLoadCli.py
pyLoadGui.py
README
scripts
setup.cfg
systemCheck.py
testlinks.txt
tests
endef

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_DIR)/.exclude: $($(PKG)_DIR)/.configured
	@echo -n > $@; \
	echo $(call newline2space,$(pyLoad/build/files)) | tr " " "\n" >> $@; \
	echo $(call newline2space,$(pyLoad/unnecessary/files)) | tr " " "\n" >> $@;

$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.exclude
	@mkdir -p $(dir $@); \
	tar -c -C $(PYLOAD_DIR) --exclude-from=$< . | tar -x -C $(dir $@); \
	touch -c $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	$(RM) $(PYLOAD_DIR)/.exclude

$(pkg)-uninstall:
	$(RM) -r $(dir $(PYLOAD_TARGET_BINARY))

$(PKG_FINISH)
