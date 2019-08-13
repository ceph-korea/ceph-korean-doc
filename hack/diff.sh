#!/bin/bash

if [[ "$BRANCH" == "" ]]; then
    echo "BRANCH not specified, checkout as master"
    BRANCH=master
fi

DIFFPATH=/tmp/ceph-korean-doc.diff

git clone --single-branch --branch $BRANCH git@github.com:ceph/ceph.git ceph.new

rm -rf ./diff
for FILE in `cat ./completed`; do
    DIFF=`git diff --patch --raw --text --no-index ./ceph.new/doc/$FILE ./ceph/doc/$FILE`
    if [[ "$DIFF" != "" ]]; then
        echo "$FILE ::----------------------------------------------------------::" >> $DIFFPATH
        echo "$DIFF" >> $DIFFPATH
        echo "" >> $DIFFPATH
    fi
done

rm -rf ./ceph.new
echo ""
if [ ! -f $DIFFPATH ]; then
    echo "No diff exists"
else
    echo "Diff file generated, check $DIFFPATH"
fi