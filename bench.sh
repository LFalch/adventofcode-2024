#!/bin/sh
set -e

echo "Day 1"
cd day01
echo "Part 1"
zig build run1 -Doptimize=ReleaseFast -- 2164381
echo "Part 2"
zig build run2 -Doptimize=ReleaseFast -- 20719933
cd ..

echo "Day 2"
cd day02
echo "Part 1"
zig build run1 -Doptimize=ReleaseFast -- 332
echo "Part 2"
zig build run2 -Doptimize=ReleaseFast -- 398
cd ..

echo "Day 3"
cd day03
echo "Part 1"
zig build run1 -Doptimize=ReleaseFast -- 189527826
echo "Part 2"
zig build run2 -Doptimize=ReleaseFast -- 63013756
cd ..

echo "Day 4"
cd day04
echo "Part 1"
zig build run1 -Doptimize=ReleaseFast -- 2554
echo "Part 2"
zig build run2 -Doptimize=ReleaseFast -- 1916
cd ..

echo "Day 5"
cd day05
echo "Part 1"
zig build run1 -Doptimize=ReleaseFast -- 4281
echo "Part 2"
zig build run2 -Doptimize=ReleaseFast -- 5466
cd ..