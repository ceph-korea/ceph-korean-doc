#!/bin/bash

FWORD=$(grep -iR $WORD ./trans/*)

echo ""
if [[ $FWORD == "" ]]; then
    echo "There are no translation results for word '$WORD'"
    echo "Please refer https://github.com/ceph-korea/ceph-korean-doc#번역-가이드"

    echo ""
    exit 0
fi

echo "Results:"
echo $FWORD | sed 's/,/ -> /g' | sed 's/:/: /g'
echo ""