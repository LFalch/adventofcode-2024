const std = @import("std");
const day1 = @import("root.zig");

fn part1(left: *day1.List, right: *day1.List) i32 {
    var sum: i32 = 0;
    for (left.slice(), right.slice()) |l, r| {
        sum += @max(l, r) - @min(l, r);
    }
    return sum;
}

pub fn main() !void {
    try day1.do(part1);
}
