#!/bin/bash

cd ceph
git submodule foreach 'git stash'
rm -rf doc.orig