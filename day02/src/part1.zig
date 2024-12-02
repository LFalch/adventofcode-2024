const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    var f = try aoc.read_input();
    const timer = aoc.Timer.start();

    var numSafe: u64 = 0;

    while (!f.is_done()) {
        var newLine = false;
        var isSafe = true;
        var lastNum: ?u8 = null;
        var direction: ?bool = null;
        while (!newLine) : (newLine = f.read_space()) {
            const num = f.read_number(u8);
            if (!isSafe) continue;
            if (lastNum) |l_num| {
                const diff: i9 = @as(i9, num) - l_num;
                if (@abs(diff) == 0 or @abs(diff) > 3) isSafe = false;
                const sign = diff > 0;
                if (direction) |d| {
                    if (sign != d) isSafe = false;
                } else direction = sign;
            }

            lastNum = num;
        }

        if (isSafe) {
            numSafe += 1;
        }
    }
    timer.stop();
    try std.io.getStdOut().writer().print("{d}\n", .{numSafe});
}
