#!/bin/bash
## 
## @(#) Test server connection to Oracle DB from C - test launcher
##
## @file run.sh
## 
## -----------------------------------------------------------------------------
## Enduro/X Middleware Platform for Distributed Transaction Processing
## Copyright (C) 2015, Mavimax, Ltd. All Rights Reserved.
## This software is released under one of the following licenses:
## GPL or Mavimax's license for commercial use.
## -----------------------------------------------------------------------------
## GPL license:
## 
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 2 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT ANY
## WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
## PARTICULAR PURPOSE. See the GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, write to the Free Software Foundation, Inc., 59 Temple
## Place, Suite 330, Boston, MA 02111-1307 USA
##
## -----------------------------------------------------------------------------
## A commercial use license is available from Mavimax, Ltd
## contact@mavimax.com
## -----------------------------------------------------------------------------
##

export TESTNAME="test047_oradb"

PWD=`pwd`
if [ `echo $PWD | grep $TESTNAME ` ]; then
    # Do nothing 
    echo > /dev/null
else
    # started from parent folder
    pushd .
    echo "Doing cd"
    cd $TESTNAME
fi;

. ../testenv.sh

export TESTDIR="$NDRX_APPHOME/atmitest/$TESTNAME"
export PATH=$PATH:$TESTDIR

export NDRX_TOUT=10

#
# Domain 1 - here client will live
#
set_dom1() {
    echo "Setting domain 1"
    . ../dom1.sh
    export NDRX_CONFIG=$TESTDIR/ndrxconfig-dom1.xml
    export NDRX_DMNLOG=$TESTDIR/ndrxd-dom1.log
    export NDRX_LOG=$TESTDIR/ndrx-dom1.log
    export NDRX_DEBUG_CONF=$TESTDIR/debug-dom1.conf

    # We need DB Config here too...

    # XA SECTION
    export NDRX_XA_RES_ID=1
    export NDRX_XA_OPEN_STR="ORACLE_XA+SqlNet=ROCKY+ACC=P/endurotest/endurotest1+SesTM=180+LogDir=./+nolocal=f+Threads=true"
    export NDRX_XA_CLOSE_STR=$NDRX_XA_OPEN_STR
    export NDRX_XA_DRIVERLIB=libndrxxaoras.so
    export NDRX_XA_RMLIB=/u01/app/oracle/product/11.2.0/dbhome_1/lib/libclntsh.so
    export NDRX_XA_LAZY_INIT=1
    # XA SECTION, END
}

#
# Generic exit function
#
function go_out {
    echo "Test exiting with: $1"
    
    set_dom1;
    xadmin stop -y
    xadmin down -y



    # If some alive stuff left...
    xadmin killall atmiclt47

    popd 2>/dev/null
    exit $1
}

rm *dom*.log
# Any bridges that are live must be killed!
xadmin killall tpbridge

set_dom1;
xadmin down -y
xadmin start -y || go_out 1

RET=0

xadmin psc
xadmin ppm
echo "Running off client"

set_dom1;
(./atmiclt47 2>&1) > ./atmiclt-dom1.log
#(valgrind --leak-check=full --log-file="v.out" -v ./atmiclt47 2>&1) > ./atmiclt-dom1.log

RET=$?

if [[ "X$RET" != "X0" ]]; then
    go_out $RET
fi

# Catch is there is test error!!!
if [ "X`grep TESTERROR *.log`" != "X" ]; then
        echo "Test error detected!"
        RET=-2
fi


go_out $RET

