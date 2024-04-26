#!/bin/tcsh
#
# run make_plan.csh. Should produce obsplans for next lunation balancing
# TNO and SNE fields as specified in make_plan.csh
#
if ( ! $?MAKE_PLAN_ROOT ) then
   echo "ERROR: environment variable MAKE_PLAN_ROOT must be set to the installation path for ls4_obsplan"
   exit
endif

set d0 = `pwd`

if ( -e exclude.fields ) rm exclude.fields
touch exclude.fields
cp $MAKE_PLAN_ROOT/conf/tesselation.dat .

echo "#### CREATING OBSPLANS #####"
$MAKE_PLAN_ROOT/scripts/make_plan.csh exclude.fields >! make_plan.out

cd $d0

echo "#### SIMULATING OBSERVATIONS OF FIRST OBSPLAN #####"
set first_plan = `ls -t *.obsplan | head -n 1`
if ( ! -e $first_plan ) then
  echo "ERROR: no obsplans to simulate"
  exit
endif

if ( ! -e sim ) mkdir sim
cp $first_plan sim
cd sim
set dt = `date +"%Y %m %d"`
echo "executing scheduler $first_plan $dt 0"
$MAKE_PLAN_ROOT/scheduler/bin/scheduler $first_plan $dt 0 >& sim.out
cd $d0
grep -e "fields" ./sim/sim.out
echo "simulation output is in file sim/sim.out"

