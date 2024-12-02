#!/bin/sh

day=$1

set -e
curl -f --cookie "session=`cat .session`" https://adventofcode.com/2024/day/$day/input > day$(printf "%02d\n" $day)/input.txt