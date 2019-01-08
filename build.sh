#!/bin/bash

rm -rf ceph/doc-orig
mv ceph/doc ceph/doc-orig

mkdir ceph/doc
cp -r ./doc-ko/* ceph/doc

./ceph/admin/build-doc