#!/bin/tcsh
#
# make_sne_plan.csh
#
# produce supernova obsplans for each night of the next lunation, starting on the
# specified date and going for the next 30 days. The night fraction allocated for
# the sne fields, and the dec range must also be specified
#
# Strategy
#
# The shell first finds the date of the new moon following the specified start date
# and finds the ra at opposition for that date (ra_opp).
# It then starts by considering fields in the rectangular range in ra and dec 
# centered at ra_opp + 2 hours with dec range dec_low to dec_high, and ra range 
# -delta_ra_west to  +delta_ra_east. It iteratively runs the scheduler, decreasing 
# the eastern edge of the rectangle as necessary, until the time required to observe
# the fields in that range is within the specified night fraction. The fields that
# the simulator actually shows observed are copied into the specified obsplan file.

#
# DLR 2010 Dec 17
#
if ( $#argv != 8 ) then
  echo "syntax: make_sne_plan.csh yyyymmdd(UT) night_fraction dec_low(deg) dec_high(deg) delta_ra_west(h) delta_ra_east(h) tno.plan output_plan"
  exit
endif
#
set obs_date0 = $argv[1]
set night_fraction = $argv[2]
set dec1 = $argv[3]
set dec2 = $argv[4]
set delta_ra_west = $argv[5]
set delta_ra_east = $argv[6]
set tno_fields = $argv[7]
set plan_name = $argv[8]
#
set l = `setenv | grep -e "MAKE_PLAN_ROOT" | wc -l`
if ( $l != 1 ) then
  echo "You must set environment variable  MAKE_PLAN_ROOT to the directory path for make_obsplan"
  exit
endif
#
#
if ( ! -e $MAKE_PLAN_ROOT ) then
   echo "can't find directory $MAKE_PLAN_ROOT"
   exit
endif
#
source $MAKE_PLAN_ROOT/conf/make_sne_plan.conf
#
#
# find date of the next new moon
#
# first get  julian date for start date
#
set d = "$obs_date0"000000
#
set jd0 = `julian $d`

#
# get jd of next new moon date
#
set l = `$BIN_PATH/get_moon_jd $jd0 $MOON_EPHEM`
if ( $#l != 5 ) then
   echo " ERROR getting new new moon date"
   exit
endif
#
set jd_new_moon = $l[1]
# 
#
# get observing circumstances on night of the next new moon
get_almanac $jd_new_moon > $TEMP_FILE
#
echo "Observing circumstance on night of new moon:"
cat $TEMP_FILE
#
# get opposition position on night of new moon
#
set l = `grep -e "Opp" $TEMP_FILE`
set opp_ra = $l[2]
set opp_dec = $l[3]
#
echo "opposition ra is $opp_ra"
echo "opposition dec is $opp_dec"
#
# get year month day on night of new moon
set l = `grep -e "Date:" $TEMP_FILE`
set year_new_moon = $l[2]
set month_new_moon = $l[3]
set day_new_moon = $l[4]
#
# Create nominal field list centered at ra0 = opp_ra + 2.0. Choose limits
# ra0 - 2 to ra0 + 2. Keep the dec range -25 to + 25
#
  set ra0 = `echo "scale=3; $opp_ra + 2.0 " | bc`
  set ra0 = `echo "scale=3; if ( $ra0 > 24.0 ) ($ra0 - 24.0 ) else $ra0" | bc`
  set ra1 = `echo "scale=3; $ra0 - $delta_ra_west " | bc`
  set ra1 = `echo "scale=3; if ( $ra1 <  0.0 ) ($ra1 + 24.0 ) else $ra1" | bc`
  set ra2 = `echo "scale=3; $ra0 + $delta_ra_east " | bc`
  set ra2 = `echo "scale=3; if ( $ra2 > 24.0 ) ($ra2 - 24.0 ) else $ra2" | bc`

#
#
# create empty exclude list
if ( -e exclude.list ) rm exclude.list
touch exclude.list
#
# add the preamble to the nominal sne plan
cp $PREAMBLE  sne.plan
cat $tno_fields >> sne.plan
#
# call get_fields to make nominal sne field list
#
echo "get_sne_fields $ra1 $ra2 $dec1 $dec2 $SNE_EXP_TIME $SNE_EXP_INTERVAL $SNE_PASSES $SNE_OBS_CODE exclude.list 0 $TESSELATION_FILE >> sne.plan"
#
$BIN_PATH/get_sne_fields $ra1 $ra2 $dec1 $dec2 $SNE_EXP_TIME $SNE_EXP_INTERVAL $SNE_PASSES $SNE_OBS_CODE exclude.list 0 $TESSELATION_FILE >> sne.plan
#
# Iteratively run the scheduler, each time shrinking the RA range, until the time taken
# to make the observations is less than the specified night fraction
# the new moon night. THis is too see how much time the fields will take
#
set done = 0
set iteration = 0
while ( ! $done )
   @ iteration = $iteration + 1
   if ( -e log.obs ) rm log.obs
   echo "scheduler sne.plan $year_new_moon $month_new_moon $day_new_moon 1 >& $TEMP_FILE"
   scheduler sne.plan $year_new_moon $month_new_moon $day_new_moon 1 >& $TEMP_FILE
   set l = `grep -e "dark night duration" $TEMP_FILE`
   if ( $#l == 0 || ! -e log.obs) then
     echo "ERROR running scheduler"
     exit
   endif
   set night_length = $l[5]
   set n_fields = `grep -e " s " log.obs | grep -e "$SNE_EXP_TIME" | wc -l`

   set area = `echo "scale = 3; $n_fields * 9" | bc`
   set sne_time = `echo "scale = 3; $n_fields * ( $SNE_EXP_TIME + $READOUT_TIME ) / 3600.0" | bc`
   set fraction = `echo "scale = 3; $sne_time / $night_length" | bc`
   set done = `echo "scale = 3; if ( $fraction < $night_fraction ) 1 else 0" | bc`
   if ( ! $done ) then
     echo "iteration : $iteration  $ra1 $ra2 $dec1 $dec2 $fraction $n_fields $area "
     set ra2 = `echo "scale = 3; $ra2 - 0.5" | bc`
     cp $PREAMBLE  sne.plan
     cat $tno_fields >> sne.plan
     $BIN_PATH/get_sne_fields $ra1 $ra2 $dec1 $dec2 $SNE_EXP_TIME $SNE_EXP_INTERVAL $SNE_PASSES $SNE_OBS_CODE exclude.list 0 $TESSELATION_FILE >> sne.plan
   endif
end
#
# copy the completed fields from the last simulation into the sne plan file and
# run the scheduler simulation once more
cp fields.completed sne.plan
scheduler sne.plan $year_new_moon $month_new_moon $day_new_moon 1 >& $TEMP_FILE
set l = `grep -e "dark night duration" $TEMP_FILE`
if ( $#l == 0 || ! -e log.obs) then
     echo "ERROR running scheduler"
     exit
endif
set night_length = $l[5]
set n_fields = `grep -e " s " log.obs | grep -e "$SNE_EXP_TIME" | wc -l`
set n_tno_fields = `grep -e " s " log.obs | grep -e "$TNO_EXP_TIME" | wc -l`
set area = `echo "scale = 3; $n_fields * 9" | bc`
set sne_time = `echo "scale = 3; $n_fields * ( $SNE_EXP_TIME + $READOUT_TIME ) / 3600.0" | bc`
set tno_time = `echo "scale = 3; $n_tno_fields * ( $TNO_EXP_TIME + $READOUT_TIME ) / 3600.0" | bc`
set fraction = `echo "scale = 3; $sne_time / $night_length" | bc`
set tno_fraction = `echo "scale = 3; $tno_time / $night_length" | bc`
printf "Done:\nra1 %7.3f\nra2 %7.3f\nnight_fraction %7.3f\nNumber of Fields %d\nArea Covered %7.3f\nTNO fraction %7.3f\n" $ra1 $ra2 $fraction $n_fields $area $tno_fraction
cp sne.plan $plan_name
#
exit
#

#
