#!/bin/bash

cd ceph
rm -rf build-doc
rm -rf src/java/doc

git submodule foreach 'git stash'
rm -rf doc.orig