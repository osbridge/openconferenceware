#!/bin/sh

cd `dirname $0`
script=$PWD/`basename $0 .sh`.rb
base=/var/www/bridgepdx_ocw
report=$base/`basename $0 .sh`.txt
cd $base/current
./script/runner -e production $script | tee $report
echo "# Saved report to: $report"
