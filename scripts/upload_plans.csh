#!/bin/tcsh
#
# upload_plans.csh
#
# upload the new obsplans in new_plans directory to the scheduler
# running on quest16 at La Silla
#
set QUEST16 = 134.171.80.151
#
if ( ! -e new_plans) then
  echo "can't find new_plans directory"
  exit
endif
cd new_plans
chmod -R 777 *
if ( -e list.txt ) rm list.txt
ls *.obsplan >! list.txt
chmod 777 list.txt
set n = `cat list.txt | wc -l`
echo " upload_plans: $n new plans to be uploaded : "
cat list.txt
ssh -l observer $QUEST16 get_obsplans.csh
