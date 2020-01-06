#!/bin/bash
source /etc/profile.d/CP.sh

DAYS=$1
DAYS="${DAYS:-7}"
DATE=$(date -d "-$DAYS day" +"%Y-%m-%d")

clear_logs () {
    rm -rf $FWDIR/log/${DATE}_*.log*
}

if type "mdsstat" > /dev/null; then
    CMAS=`mdsstat | egrep "\|\s+CMA\s+\|" | awk '{print $6}'`
    for CMA in $CMAS
    do
        mdsenv $CMA
        clear_logs
    done
    mdsenv
else
    clear_logs
fi