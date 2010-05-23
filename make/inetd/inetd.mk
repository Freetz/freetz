$(call PKG_INIT_BIN, 0.2)
$(PKG)_PKG_VERSION:=$($(PKG)_VERSION)
$(PKG)_PKG_NAME:=inetd-$($(PKG)_PKG_VERSION)
$(PKG)_STARTLEVEL=20

$(PKG_UNPACKED)

$(pkg):

$(pkg)-precompiled:

$(pkg)-clean:

$(PKG_FINISH)
