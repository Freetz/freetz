#!/bin/sh 
PARALLELMFLAGS="-j 2" make kernel-toolchain 
make -j 2 target-toolchain
make -j 2 packages-precompiled