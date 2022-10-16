_comma:=,
_empty:=
_space:=$(empty) $(empty)
_hash:=\#
_bang:=!
_dollar:=$$

define _newline


endef

# a magic string that is very unlikely to appear in real strings, generated using:
#  echo -n _space_escape | sha1sum | sha1sum | cut -d " " -f 1
_space_escape:=23e5fcb635d4b5f2e6809257b10bb7aba88848bd
