#!/bin/bash
source /etc/bashrc

SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`

collect_logs () {
    cp $SCRIPTPATH/logexport.ini $FWDIR/conf/logexport.ini

    NAME=$1
    FILES=`find $FWDIR/log/*.log -mmin -360`
    for f in $FILES ; do
        echo "Extracting $f"
        FILE_NAME=`basename $f`
        `fwm logexport -n -p -m raw -i "$f" -o "$SCRIPTPATH/tmp/$NAME-$FILE_NAME"`
    done
    
    rm -f $FWDIR/conf/logexport.ini
    
}

mkdir -p $SCRIPTPATH/tmp
if type "mdsstat" > /dev/null; then
    CMAS=`mdsstat | egrep "\|\s+CMA\s+\|" | awk '{print $6}'`
    for CMA in $CMAS
    do
        mdsenv $CMA
        collect_logs $CMA
    done
    mdsenv
else
    collect_logs "ALL"
fi

cat $SCRIPTPATH/tmp/*.log | grep -v "num;" > $SCRIPTPATH/tmp/all.csv