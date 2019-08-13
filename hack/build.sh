#!/bin/bash

rm -rf ceph/doc.orig
mv ceph/doc ceph/doc.orig

mkdir ceph/doc
cp -r ./ceph-korean-doc/* ceph/doc

./ceph/admin/build-doc
