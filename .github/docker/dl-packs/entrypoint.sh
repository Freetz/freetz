#!/bin/bash
[ "$#" -gt 0 ] && su "$BUILD_USER" -c "$@" || su "$BUILD_USER"
