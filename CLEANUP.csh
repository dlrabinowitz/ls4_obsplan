#!/bin/tcsh

set d0 = `pwd`
set paths = ( $d0/bin $d0/src $d0/scheduler/src )
foreach p ($paths)
  if ( ! -e $p ) then
     echo "ERROR: can't find path $p"
     exit
  endif
end

rm $d0/bin/*
cd $d0/src
make clean
cd $d0/scheduler/src
make clean
cd $d0
