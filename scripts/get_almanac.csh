#!/bin/csh
#
# get_almanac.csh
#
# syntax: get_almanac.csh yyyy mm dd
#
# return position and phase of moon using calls to skycalc
#
set SCRIPT_PATH = "../scripts"
set CONF_PATH = "../conf"
set BIN_PATH = "../bin"
#
alias julian '$BIN_PATH/julian'
alias skycalc '$BIN_PATH/skycalc'
#
if ( $#argv != 3  && $#argv != 6 && $#argv != 1 ) then
  echo "syntax: get_almanac.csh [yyyy mm dd] or [yyyy mm dd hh mm ss] or [ JD] "
  exit
endif
#
if ( $#argv == 6 ) then
   set year = $argv[1]
   set month = $argv[2]
   set month = `echo "scale=0; $month  + 0" | bc`
   set day = $argv[3]
   set day = `echo "scale=0; $day  + 0" | bc`
   set hour = $argv[4]
   set hour = `echo "scale=0; $hour + 0" | bc`
   set min = $argv[5]
   set min = `echo "scale=0; $min  + 0" | bc`
   set sec = $argv[6]
   set sec = `echo "scale=0; $sec  + 0" | bc`
   set dstring = `printf "%04d%02d%02d%02d%02d%02d" $year $month $day $hour $min $sec`
   set jd = `julian $dstring`
endif
#
if ( $#argv == 3 ) then
   set year = $argv[1]
   set month = $argv[2]
   set month = `echo "scale=0; $month  + 0" | bc`
   set day = $argv[3]
   set day = `echo "scale=0; $day  + 0" | bc`
   set dstring = `printf "%04d%02d%02d%s" $year $month $day "000000"`
   set jd = `julian $dstring`
endif
#
if ( $#argv == 1 ) then
   set jd = $argv[1]
endif
#
set d = `date +"%H%M%S"`
set TEMP_FILE  = "/tmp/sky_calc.tmp"
set TEMP_FILE1  = "/tmp/sky_calc.tmp1"
set TEMP_FILE2  = "/tmp/sky_calc.tmp2"

#
# observatory is La Silla 
echo "e" >! $TEMP_FILE
#
# set Julian Date
echo "xJ $jd" >> $TEMP_FILE
#
# enter commands to get circumstances and major planet positions
#
echo "a" >> $TEMP_FILE
echo "m" >> $TEMP_FILE
#
# enter exit command
#
echo "Q" >> $TEMP_FILE
#
# execute command script
#
skycalc < $TEMP_FILE >! $TEMP_FILE1
#
# Get Moon phase and position from output
#
grep -e "Moon " $TEMP_FILE1 >! $TEMP_FILE2
set l = `cat $TEMP_FILE2 | head -n 1 | tail -n 1`
set phase = $l[7]
#
set l = `head -n 2 $TEMP_FILE2 | tail -n 1`
set moon_ra_h = `printf "%7.3f" $l[3]`
set moon_ra_m = `printf "%7.3f" $l[4]`
set moon_dec_d = `printf "%7.3f" $l[5]`
set moon_dec_m = `printf "%7.3f" $l[6]`
set moon_ra = `echo "scale=3; $moon_ra_h + ($moon_ra_m/60.0)" | bc`
set moon_dec = `echo "scale=3; $moon_dec_d + ($moon_dec_m/60.0)" | bc`
#
grep -e "Sun " $TEMP_FILE1 >! $TEMP_FILE2
set l = `head -n 2 $TEMP_FILE2 | tail -n 1`
set sun_ra_h = `printf "%7.3f" $l[3]`
set sun_ra_m = `printf "%7.3f" $l[4]`
set sun_dec_d = `printf "%7.3f" $l[5]`
set sun_dec_m = `printf "%7.3f" $l[6]`
set sun_ra = `echo "scale=3; $sun_ra_h + ($sun_ra_m/60.0)" | bc`
set sun_dec = `echo "scale=3; $sun_dec_d + ($sun_dec_m/60.0) " | bc`
set opp_ra = `echo "scale=3; $sun_ra + 12.0" | bc`
set opp_ra = `echo "scale=3; if ( $opp_ra > 24.0 ) ( $opp_ra - 24.0 ) else $opp_ra" | bc`
set opp_dec = `echo "scale=3; 0.0 - $sun_dec" | bc`
#
# get julian date from output
grep -e "Julian date" $TEMP_FILE1 > $TEMP_FILE2
set l = `cat $TEMP_FILE2`
set jd = $l[3]
#
# get year mon day from output
grep -e "Local midnight" $TEMP_FILE1 > $TEMP_FILE2
sed "s/,//g" $TEMP_FILE2 > $TEMP_FILE1
mv $TEMP_FILE1 $TEMP_FILE2
cat $TEMP_FILE2
set l = `cat $TEMP_FILE2`
set year = $l[4]
set m = $l[5]
set day = $l[6]
set names = `echo "Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec"`
set i = 1
set month = "unknown"
while ( $i <= $#names )
  if  ( $m == $names[$i] ) then
       set month = `printf "%02d" $i`
  endif
  @ i = $i + 1
end
#
echo "Date: $year $month $day $jd"
echo "Moon: $phase $moon_ra $moon_dec"
echo "Sun:  $sun_ra $sun_dec"
echo "Opp: $opp_ra $opp_dec"
#
