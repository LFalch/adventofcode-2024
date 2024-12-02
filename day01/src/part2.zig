const std = @import("std");
const day1 = @import("root.zig");

fn part2(left: *std.ArrayList(i64), right: *std.ArrayList(i64)) i128 {
    var sum: i128 = 0;

    var j: usize = 0;
    var lastEl: i64 = -1;
    var lastProd: i128 = undefined;
    for (left.items) |el| {
        if (lastEl != el) {
            var multiplier: i64 = 0;
            while (j < right.items.len and right.items[j] < el) : (j += 1) {}
            while (j < right.items.len and right.items[j] == el) : (j += 1) {
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
