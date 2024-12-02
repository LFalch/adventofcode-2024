#!/bin/sh

day=$1
daystring="day$(printf "%02d\n" $day)"
set -e
cp -r dayXX $daystring
./grabinput.sh $1
