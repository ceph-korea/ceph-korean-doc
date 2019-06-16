#!/bin/bash

echo "Overwriting old dependency requirements..."
cat >./ceph/admin/doc-requirements.txt <<EOF
Sphinx == 1.8.3
git+https://github.com/ceph/sphinx-ditaa.git@py3#egg=sphinx-ditaa
# newer versions of breathe will require Sphinx >= 2.0.0 and are Python3 only
breathe==4.12.0
# 4.2 is not yet release at the time of writing, to address CVE-2017-18342,
# we have to use its beta release.
pyyaml>=4.2b1<Paste>
EOF

rm -rf ceph/doc-orig
mv ceph/doc ceph/doc-orig

mkdir ceph/doc
cp -r ./doc-ko/* ceph/doc

./ceph/admin/build-doc
