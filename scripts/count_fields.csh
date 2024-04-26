#!/bin/tcsh
#
# count_fields.csh
#
# foreach each field in a specified obsplan, query the
# quest_db to find the number of times the field has been
# observed since a given start date. Require each field to
# have mag_limit > MIN_MAG_LIMIT and fwhm < MAX_FWHM.
# If a field has been
# observed less than 7 times, copy the line to the "todo.fields"
# and append with the priority (7 - count). Otherwise, 
# append to the "done.fields" appended with the count
#
# include count of 180-s exposures also. DLR 2011 May 5
#
unalias cp
unalias rm
#
set MIN_MAG_LIMIT = 20.0
set MAX_FWHM = 3.0
#
#
if ( $#argv != 4 ) then
   echo "syntax: count_fields.csh reference_obsplan start_date(yyyymmdd) todo_file done_file"
   exit
endif
#
set obsplan = $argv[1]
set start_date = $argv[2]
set todo_file = $argv[3]
set done_file = $argv[4]
#

if ( ! -e $obsplan ) then
  echo "can't find obsplan at $obsplan"
  exit
endif
#
set QUEST_DB_ORIG = /group/astro/db/quest_db.db
#
if ( ! -e $QUEST_DB_ORIG ) then
  echo "can't find quest database at $QUEST_DB_ORIG"
  exit
endif
#
if ( -e ./quest_db.db) rm quest_db.db
cp $QUEST_DB_ORIG ./quest_db.db
chmod 777 ./quest_db.db
#
set n = `cat $obsplan | wc -l`
set i = 1
while ( $i <= $n )
  set l = `head -n $i $obsplan | tail -n 1`
  if ( $#l >= 9 ) then
    set field_id = $l[9]
#    set l1 = `echo "select id, rlim1, fwhm from quest_db where id > $start_date and field_id = $field_id and req_expt = 60 and obs_type = 's';" | sqlite3 -separator " " quest_db.db`
#    set count = `echo "select count(id) from quest_db where id > $start_date and field_id = $field_id and req_expt = 60 and obs_type = 's' and fwhm < $MAX_FWHM and rlim1 > $MIN_MAG_LIMIT;" | sqlite3 -separator " " quest_db.db`
    set count = `echo "select count(id) from quest_db where id > $start_date and field_id = $field_id and obs_type = 's' and fwhm < $MAX_FWHM and rlim1 > $MIN_MAG_LIMIT;" | sqlite3 -separator " " quest_db.db`
    echo $field_id $count 
    @ priority = 7 - $count
    if ( $priority > 0 ) then
        echo $l $priority  >> $todo_file
    else 
        echo $l $count >> $done_file
    endif
  endif
  @ i = $i + 1
end

#
