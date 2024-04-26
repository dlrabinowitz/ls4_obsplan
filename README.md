# ls4_obsplan
code to create and simulate obsplans for the LSQ scheduler


original README from 20210 Aug 6 with slight change to add scheduler code
make_obsplan
DLR 2010 Aug 6

DLR 2024 04 26
restore from archived CVS repository
add scheduler code to distribution
submit to github


Scripts and code to make La Silla QUEST obsplans for the next 30 days

The main script, make_plan, is in the scripts directory. It calls other
scripts and binary executables in the bin and scripts directory. Included
in the src is skycalc, freeware to determine observing circumstances for
any given site at any given time. Program get_fields reads the tesselation
file and creates the field schedule in the format expected by the LA SIlla
scheduler.

to compile:

cd src
make clean
make
make install
cd ../scheduler
cd src
make clean
make
make install
cd ../..

to run:

setenv MAKE_PLAN_ROOT to the path where this code was installed

make a directory to store the obsplans
change to that directory
copy make_plan from the scripts directory into the directory
copy or link in the tesselation.dat file from the conf directory
create an file of fields to exclude (same format as the obsplans themselves)
run make_fields filename, where filename is the name of the excludes file

to test:
  cd $MAKE_PLAN_ROOT
  mkdir test
  cd test
  ../scripts/test.csh
