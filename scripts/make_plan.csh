#!/bin/tcsh
#
# make_plan.csh
#
# produce obsplans for each night of the next lunation, starting on the
# current date and going for the next 30 days. To balance the
#  the time for TNO and SNE fields to  specified totals, and to fit within
# the night-time hours, you have to adjust fixed parameters in this shell by
# trial and error.
#
# The shell first finds the date of the next new moon. THen finds the ra, dec
# of opposition on the date. It then chooses the RA and Dec range for
# the TNO and SNE fields relative to opposition. On bright nights (outside of
# the 18 nights centered on new moon), the range for the SNE fields is
# extended relative to the dark nights when TNO fields are also being
# taken.
#
# Diffferent TNO fields are observed every dark night, whereas single set
# of SNE fields is observed every night for bright time, and another single set of SNE
# fields is observed every night for dark time
#
# To balance the TNO/SNE night fraction, the DEC range of the TNO fields
# and the RA and DEC range of the SND fields must be adjusted by
# trial and error. See variables ra1,ra2,ra3,dec1,SNE_DEC_LOW, SNE_DEC_HIGH,
# TNO_DEC_LOW, and TNO_DEC_HIGH
#
# This version was tuned for Jul 2010 run (10 hour nights).
#
# DLR 2010 Aug 6
#
#
# the shell expects the name of the file with the tno fields to exclude
# in the new obsplans. THe format is indentical to the obsplan itself
#
if ( $#argv != 1 ) then
  echo "syntax: make_plan.csh exclude_list"
endif
#
set exclude_list = $argv[1]
if ( ! -e $exclude_list ) then
  echo "can't find file $exclude_list"
  exit
endif
#
#
# set SNE_SEARCH to 1 to make sne fields. Set to 0 for TNO fields only
set SNE_SEARCH = 1
#
#
set SCRIPT_PATH = "../scripts"
set CONF_PATH = "../conf"
set BIN_PATH = "../bin"
#
set TEMP_FILE = "make_plan.tmp"
alias julian '$BIN_PATH/julian'
alias get_fields '$BIN_PATH/get_fields'
alias get_almanac '$SCRIPT_PATH/get_almanac.csh'
#
# Set the fixed exposure times and intervals
# for TNO and SNe fields.
#
set TNO_EXP_TIME = 180.0
set SNE_EXP_TIME = 60.0
set READOUT_TIME = 40.0
set TNO_EXP_INTERVAL = 7200.0
set SNE_EXP_INTERVAL = 3600.0
set TNO_PASSES = 3
set SNE_PASSES = 2
#
# Fix the obs codes for TNO and SNE fields. USe 3 for TNOS (must do).
# This puts them at higher priority than the SNE fields.
#
set TNO_OBS_CODE = 3
set SNE_OBS_CODE = 2
#
#
# find date of the next new moon
#
# first get current julian date
set  d = `date +"%Y%m%d%H%M%S"`
#set d = "20100429000000"
set jd0 = `julian $d`
#
# get current phase of the moon
set l = `get_almanac $jd0 | grep -e "Moon"`
set phase = $l[2]
#
# keep advancing jd by one day  until new moon is found
#
echo "Finding next new moon date"
#
set jd = $jd0
set new_moon = 0
set iterations = 0
while ( (! $new_moon) && $iterations < 30) 
  set new_moon = `echo "scale=6; if ( $phase < 0.01 ) 1 else 0" | bc`
  if ( ! $new_moon ) then
     set jd = `echo "scale=6; $jd + 1.0" | bc`
     set l = `get_almanac $jd | grep -e "Moon"`
     set phase = $l[2] 
  endif
  @ iterations = $iterations + 1
end  
#
if ( ! $new_moon ) then
  echo "new moon not found"
  exit
endif
#
# determine julian date on start and end dates of the dark time.
set jd_new_moon = $jd
set jd_tno_start = `echo "scale=6; $jd_new_moon - 8.0 " | bc`
set jd_tno_end = `echo "scale=6; $jd_new_moon + 9.0 " | bc`
#
#
# get observing circumstances on night of the next new moon
get_almanac $jd > $TEMP_FILE
#
echo "Observing circumstance on night of new moon:"
cat $TEMP_FILE
#
echo "start tno fields on $jd_tno_start"
echo "end tno fields on $jd_tno_end"
#
# determine the number of nights TNOs will be observed (may not be
# 18 if start date is changed by hand in the script"
#
set n = `echo "scale=0; $jd_tno_end - $jd_tno_start + 1" | bc`
set num_tno_nights = `printf "%03.0f" $n`
echo "num tno nights $num_tno_nights"
#
# get opposition position at new moon
#
set l = `grep -e "Opp" $TEMP_FILE`
set opp_ra = $l[2]
set opp_dec = $l[3]
#
echo "opposition ra is $opp_ra"
echo "opposition dec is $opp_dec"
#
#
set TNO_DEC_LOW = -90
set TNO_DEC_HIGH = 20.0
# choose TNO fields from -2 to +2 hours of opposition, TNO_DEC_LOW to TNO_DEC_HIGH  deg dec
# above and below opposition dec
#
set ra1 = `echo "scale=3; $opp_ra - 2.0 " | bc`
set ra1 = `echo "scale=3; if ( $ra1 < 0.0 ) ($ra1 + 24.0 ) else $ra1" | bc`
set ra2 = `echo "scale=3; $opp_ra + 2.0 " | bc`
set ra2 = `echo "scale=3; if ( $ra2 > 24.0 ) ($ra2 - 24.0 ) else $ra2" | bc`
set dec1 = `echo "scale=3; $opp_dec + $TNO_DEC_LOW" | bc`
set dec2 = `echo "scale=3; $opp_dec + $TNO_DEC_HIGH" | bc`
#
# call get_fields, which finds determines which fields on the tesselation grid are
# within the specified range, excludes fields too close to the galactic plane
# (hardwired as 15 deg in the source code), and excludes fields in the exclude
# list specified on this scripts command line. THe output are the fields in
# the format expected by the night-time scheduler at La Silla. With the final
# command-line argument set to "1", get_fields also outputs dec-offset fields
# to fill the dec-gaps in the CCD array. Fix the number of passes as 3, the
# obscode as 3 ("must do"), and the time interval between pass
# at 7200.0 seconds.
#
echo "get_fields $ra1 $ra2 $dec1 $dec2 $TNO_EXP_TIME $TNO_EXP_INTERVAL $TNO_PASSES $TNO_OBS_CODE $exclude_list 1 > tno.fields"
get_fields $ra1 $ra2 $dec1 $dec2 $TNO_EXP_TIME $TNO_EXP_INTERVAL $TNO_PASSES $TNO_OBS_CODE $exclude_list 1 > tno.fields
#
# separate the normal and dec-offset fields into two files
#
grep -e "offset" tno.fields >! tno.fields.offset
grep -ve "offset" tno.fields >! tno.fields.no_offset
#
#
# if SNE fields are also to be scheduled, determine the positions for dark and bright
# time separately
#
if ( $SNE_SEARCH == 1 ) then
#
# choose SNe fields in bright time from -2 to +3.5 hours of opposition (ra1 to ra2), and
# in dark time from -2 to +0.75 hours (ra1 to ra3). These offsets were tuned by trial and error
# for the given lunation. The same bright fields will be observed every night of bright time,
# and the same dark fields will be observed every night of dark time.
#
  set ra1 = `echo "scale=3; $opp_ra - 2.0 " | bc`
  set ra1 = `echo "scale=3; if ( $ra1 < 0.0 ) ($ra1 + 24.0 ) else $ra1" | bc`
  set ra2 = `echo "scale=3; $opp_ra + 3.5 " | bc`
  set ra2 = `echo "scale=3; if ( $ra2 > 24.0 ) ($ra2 - 24.0 ) else $ra2" | bc`
  set ra3 = `echo "scale=3; $opp_ra + 0.75" | bc`
  set ra3 = `echo "scale=3; if ( $ra3 > 24.0 ) ($ra3 - 24.0 ) else $ra3" | bc`
#
# set the dec range of the sne fields for bright and dark time.
#
  set SNE_DEC_LOW_DARK = -9.0  
  set SNE_DEC_HIGH_DARK = 9.0 
  set SNE_DEC_LOW_BRIGHT = -12.0
  set SNE_DEC_HIGH_BRIGHT = 12.0
#
# create an empty exclude list.
#
  if ( -e /tmp/temp.list ) rm /tmp/temp.list
  touch /tmp/temp.list
  set exclude_list = "/tmp/temp.list"
#
# call get_fields to determine SNE pointings for dark and bright time 
#
  echo "get_fields $ra1 $ra3 $SNE_DEC_LOW_DARK $SNE_DEC_HIGH_DARK $SNE_EXP_TIME $SNE_EXP_INTERVAL $SNE_PASSES $SNE_OBS_CODE $exclude_list 0 > sne.fields_dark"
#
  get_fields $ra1 $ra3 $SNE_DEC_LOW_DARK $SNE_DEC_HIGH_DARK $SNE_EXP_TIME $SNE_EXP_INTERVAL $SNE_PASSES $SNE_OBS_CODE $exclude_list 0 > sne.fields_dark
#
  echo "get_fields $ra1 $ra2 $SNE_DEC_LOW_BRIGHT $SNE_DEC_HIGH_BRIGHT $SNE_EXP_TIME $SNE_EXP_INTERVAL $SNE_PASSES $SNE_OBS_CODE 2 $exclude_list 0 > sne.fields_bright"
#
  get_fields $ra1 $ra2 $SNE_DEC_LOW_BRIGHT $SNE_DEC_HIGH_BRIGHT $SNE_EXP_TIME $SNE_EXP_INTERVAL $SNE_PASSES $SNE_OBS_CODE $exclude_list 0 > sne.fields_bright
#
else
#
# if no SNE fields are to be observed, write empty bright and dark time lists
  echo "" >! sne.fields_dark
  echo "" >! sne.fields_bright
endif
#
#
# count the number of sne fields for dark and bright time are report them.
#
set n_fields = `cat sne.fields_dark | wc -l`
echo "$n_fields dark sne fields "
#
set n_fields = `cat sne.fields_bright | wc -l`
echo "$n_fields bright sne fields "
#
# count and report the total number of TNO fields to be observed in dark time
set n_fields = `cat tno.fields | wc -l`
#
echo "$n_fields TNO fields total"
#
# count and report the normal and dec-offset tno fields
#
set n_offset_fields = `cat tno.fields.offset | wc -l`
set n_no_offset_fields = `cat tno.fields.no_offset | wc -l`
#
echo "$n_offset_fields offset TNO fields total"
echo "$n_no_offset_fields no offset TNO fields total"
#
# calculate the number of tno fields to observe per night as simply the total
# number of fields divided by the number of nights
#
set x = `echo "scale=3; $n_fields / $num_tno_nights" | bc`
set fields_per_night = `printf "%3.0f" $x`
#
# calculate and report the time time per night (in hrs) for observing TNO fields
#
set tno_time = `echo "scale=3; $fields_per_night* 3 * ( $READOUT_TIME + $TNO_EXP_TIME ) / 3600.0" | bc`
echo "$fields_per_night tno fields per night  $tno_time hours"
#
#
# Loop through each night of the next 30 nights and create the obsplan for each night.
# Alternate plans for offset and normal TNO fields every other dark night.
#
set i = 1
set total_fields = 0
set total_fields_offset = 0
set total_fields_no_offset = 0
set jd = $jd0
while ( $i < 30 )
#
# even nights are for dec-offset fields, odd for normal
#
# if i is even, set offset_night = 1. Otherwise, set it to 0
  @ j = $i / 2
  @ j = $j * 2
  if ( $i == $j ) then
    set offset_night = 1
  else
    set offset_night = 0
  endif
#
# determine the name for the file for the night's obsplan. Must be named
# yyyymmdd.obsplan where yyyymmdd is the UT date of the morning time
#
  get_almanac $jd > $TEMP_FILE
  set l = `grep -e "Date" $TEMP_FILE`
  set year = $l[2]
  set month = $l[3]
  set day = $l[4]
  set year = `echo "scale=0; $year + 0" | bc`
  set month = `echo "scale=0; $month + 0" | bc`
  set day = `echo "scale=0; $day + 0" | bc`
  set field_name = `printf "%04d%02d%02d.obsplan" $year $month $day`
  echo "# La Silla Quest obsplan for $year $month $day" 
  echo "# La Silla Quest obsplan for $year $month $day" >! $field_name
#
# put a preamble into the obsplan, depending on if it is a dark night (with
# TNO exposures) or not. If bright, use the preamble for bright time. For
# dark, use the dark preamble. THe difference is whether or not to take
# darks with the same exposure time as the TNO fields (assimed to be 180
# seconds in the preambles... change the preamble files if this is not the
# case ). Also append the respective SNE fields.
#
# Bright nights before new moon
  if ( `echo "scale=6; if ( $jd < $jd_tno_start ) 1 else 0" | bc` ) then
     cat $CONF_PATH/preamble_bright.plan >> $field_name
     cat sne.fields_bright >> $field_name
# bright nights after new moon
  else if ( `echo "scale=6; if ( $jd > $jd_tno_end ) 1 else 0" | bc` ) then
     cat $CONF_PATH/preamble_bright.plan >> $field_name
     cat sne.fields_bright >> $field_name
# dark nights
  else
     cat $CONF_PATH/preamble_dark.plan >> $field_name
#
#    append the TNO fields, choosing normal or offset fields as determined 
#    above. Choose the next n fields in the respective list, where ni is
#    the number of fields per night calculated above. 
#
     if ( $offset_night ) then
#
#      set k to the number of offset fields remaining to be observed
#
       @ k = $n_offset_fields - $total_fields_offset
#
#      if k is larger than the number planned per night (fields_per_night), then just append
#      the next fields_per_night offset fields to the obsplan
#
       if ( $k >= $fields_per_night ) then
          echo "$fields_per_night offset fields: $year $month $day"
          @ total_fields_offset = $total_fields_offset + $fields_per_night
          head -n $total_fields_offset tno.fields.offset | tail -n $fields_per_night >> $field_name
#
#      otherwise, append only the number of fields remaining in the file. This should be the
#      last night. If there are no more fields, report that.
       else
          if ( $k <= 0 ) then
              echo "run out of offset fields: $year $month $day"
          else 
             echo "only $k offset fields remaining: $year $month $day" 
             set total_fields_offset = $n_offset_fields
             head -n $total_fields_offset tno.fields.offset | tail -n $k >> $field_name
          endif
       endif
#
#    For normal, non offset fields, do the same thing as above
     else
       @ k = $n_no_offset_fields - $total_fields_no_offset
       if ( $k >= $fields_per_night ) then
          echo "$fields_per_night unoffset fields: $year $month $day"
          @ total_fields_no_offset = $total_fields_no_offset + $fields_per_night
          head -n $total_fields_no_offset tno.fields.no_offset | tail -n $fields_per_night >> $field_name
       else
         if ( $k <= 0 ) then
             echo "run out of unoffset fields: $year $month $day"
         else 
             echo "only $k unoffset fields remaining: $year $month $day" 
             set total_fields_no_offset = $n_no_offset_fields
             head -n $total_fields_no_offset tno.fields.no_offset | tail -n $k >> $field_name
         endif
       endif
     endif
#    
#    finally, append the dark-night sne fields
#
     cat sne.fields_dark >> $field_name
  endif
#
# count the number of tno and sne fields in the obsplan, calculate the time to observe them
# and report the numbers.
  set n_tno_fields = `cat $field_name | grep -e " 3 3 " | wc -l`
  set n_sne_fields = `cat $field_name | grep -e " 2 2 " | wc -l`
  set tno_time = `echo "scale=3; $n_tno_fields * ( $READOUT_TIME + $TNO_EXP_TIME ) * $TNO_PASSES / 3600.0" | bc`
  set sne_time = `echo "scale=3; $n_sne_fields * ( $READOUT_TIME + $SNE_EXP_TIME ) * $SNE_PASSES / 3600.0" | bc`
  echo "field $field_name :  $n_tno_fields tno fields   $n_sne_fields sne fields  $tno_time $sne_time" 
#
# go on to the next night
  @ i = $i + 1
  set jd = `echo "scale=6; $jd + 1.0" | bc`
end
#


