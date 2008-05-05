$(call PKG_INIT_BIN, 1.11)
$(PKG)_PKG_SOURCE:=callmonitor-$(CALLMONITOR_VERSION)-freetz.tar.bz2
$(PKG)_PKG_SITE:=http://download.berlios.de/callmonitor
$(PKG)_STARTLEVEL=30

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$(pkg):

$(pkg)-precompiled:

$(pkg)-clean:

$(PKG_FINISH)
