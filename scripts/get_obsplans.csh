#!/bin/tcsh
#
# script to read obsplans from website at Yale and 
# place them in the appropriate directories on quest16
#
# DLR 2010 12 15
unalias rm
unalias cp
#
set PROG_NAME = "get_obsplans.csh"
set TEST = 0
#
if ( $TEST == 1 ) then
  set obsplans_dir = /home/observer/obsplans/test
else
  set obsplans_dir = /home/observer/obsplans
endif
set web_page = http://www.yale.edu/quest/sedna/obsplans
set list_name = "list.txt"
set new_plans_dir = "new_plans"
#
if ( ! -e $obsplans_dir ) then
   echo "ERROR: can't find $obsplans_dir"
   exit
endif
#
cd $obsplans_dir
#
if ( -e $list_name) rm $list_name
if ( -e $new_plans_dir) rm -r $new_plans_dir
mkdir $new_plans_dir
cd $new_plans_dir
#
# get listing of new plans
#
echo " $PROG_NAME : getting list of new plans from $web_page"
#
wget $web_page/$list_name
#
echo " $PROG_NAME : new obsplans are : "
cat $list_name
set n_plans = `cat $list_name | wc -l`
#
echo "$PROG_NAME : download and installing new plans"

# for each entry in list call wget again
#
set i = 0
foreach plan (`cat $list_name` )
  echo " $PROG_NAME : getting $plan"
  wget -O $plan $web_page/$new_plans_dir/$plan >& /tmp/get_obsplans.tmp
  if ( ! -e $plan ) then
     echo " $PROG_NAME : ERROR could not download plan $plan"
     cat /tmp/get_obsplans.tmp
     exit
  endif
  set n = `cat $plan | wc -l`
  if ( $n == 0 ) then
     echo " $PROG_NAME : ERROR downloading obsplan"
     cat /tmp/get_obsplans.tmp
     exit
  endif
  set d = `echo $plan | cut -c 1-8`
  if ( ! -e $obsplans_dir/$d ) mkdir $obsplans_dir/$d
  echo "cp $plan $obsplans_dir/$d"
  cp $plan $obsplans_dir/$d
  if ( ! -e $obsplans_dir/$d/$plan ) then
     echo " $PROG_NAME : ERROR could not install plan $plan"
     exit
  endif
  @ i = $i + 1
end
if ( $i == $n_plans) then
   echo " $PROG_NAME : all $n_plans plans succesfully installed"
else
   echo " $PROG_NAME : ERROR only $i plans of $n_plans installsed"
endif
#
