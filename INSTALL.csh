#!/bin/tcsh

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

