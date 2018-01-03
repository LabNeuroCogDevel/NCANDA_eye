#!/usr/bin/env bash

cd $(dirname $0)
eydroot=$(pwd)/../Data/Eye-trac\ Data/
[ ! -d "$eydroot" ] && echo "no files in $eydroot" && exit 1
eydroot=$(cd "$eydroot";pwd)

find "$eydroot" -type f -iname '*eyd' | while read f; do
 ./scoreOne.bash "$f"
done
