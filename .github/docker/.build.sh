#!/bin/bash
MYPWD="$(dirname $(realpath $0))"
cd $MYPWD

BATCH="${0##*/}"
[ "$BATCH" == ".build.sh" ] && echo 'Do not run this file' && exit 1

IMG="${BATCH%.sh}"
USR="${1:-freetzng}"
TAG="$(crc32 <(date +%s))"

sudo docker pull $(sed -n 's/^FROM //p' $IMG/Dockerfile) && \
sudo docker build --no-cache --compress -t $USR/$IMG:$TAG $IMG/ && \
sudo docker push $USR/$IMG:$TAG && \
sudo docker tag $USR/$IMG:$TAG $USR/$IMG:latest && \
sudo docker push $USR/$IMG:latest && \
echo done

