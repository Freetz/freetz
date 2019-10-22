#!/bin/bash
# generates patches/README.md
MYPWD="$(dirname $(realpath $0))"

echo todo | tee "$MYPWD/README.md"

