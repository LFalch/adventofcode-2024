const std = @import("std");
const day1 = @import("root.zig");

fn part1(left: *std.ArrayList(i32), right: *std.ArrayList(i32)) i32 {
    var sum: i32 = 0;
    for (left.items, right.items) |l, r| {
        sum += @max(l, r) - @min(l, r);
    }
    return sum;
}

pub fn main() !void {
    try day1.do(part1);
}
