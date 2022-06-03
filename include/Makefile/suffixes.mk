# to debug suffixes: make olddefconfig -d
# "--no-builtin-rules" gets inherited
# ".SUFFIXES:" gets overwritten
%: %.o
%: %.c
%: %.cc
%: %.C
%: %.cpp
%: %.p
%: %.f
%: %.F
%: %.m
%: %.r
%: %.s
%: %.S
%: %.mod
%: %.sh
%: %,v
%: %,v
%: RCS/%,v
%: RCS/%
%: s.%
%: SCCS/s.%
%: %.o

