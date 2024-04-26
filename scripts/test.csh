#!/bin/tcsh
#
# run make_plan.csh. Should produce obsplans for next lunation balancing
# TNO and SNE fields as specified in make_plan.csh
#
if ( -e exclude.fields ) rm exclude.fields
touch exclude.fields
cp ../conf/tesselation.dat .
../scripts/make_plan.csh exclude.fields
