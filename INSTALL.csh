#!/bin/tcsh

if (! -e bin) mkdir bin
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

