#!/bin/csh
#
# sort.csh
#
if ( $#argv != 3 ) then
   echo "syntax: sort.csh column input_file output_file"
   exit
endif
#
if ( $argv[1] < 0 ) then
   set r = 1
   set a = 0
   @ a = 0 - $argv[1]
else
   set r = 0
   set a = $argv[1]
endif
@ n = $a - 1
if ( $r == 0 ) then
   sort -n +$n -$a $argv[2] >! $argv[3]
else
   sort -n -r +$n -$a $argv[2] >! $argv[3]
endif

