const std = @import("std");
const day1 = @import("root.zig");

fn part2(left: *day1.List, right: *day1.List) i32 {
    var sum: i32 = 0;

    var j: usize = 0;
    var lastEl: i32 = -1;
    var lastProd: i32 = undefined;
    for (left.slice()) |el| {
        if (lastEl != el) {
            var multiplier: i32 = 0;
            while (j < right.len and right.buffer[j] < el) : (j += 1) {}
            while (j < right.len and right.buffer[j] == el) : (j += 1) {
                multiplier += 1;
            }
            lastProd = el * multiplier;
        }
        sum += lastProd;
        lastEl = el;
    }
    return sum;
}

pub fn main() !void {
    try day1.do(part2);
}
