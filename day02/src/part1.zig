const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    try aoc.main_with_bench(u16, {}, solve);
}

fn solve(fd: aoc.FileData, _: void) u16 {
    var f = fd;
    var numSafe: u16 = 0;

    while (!f.is_done()) {
        var newLine = false;
        var isSafe = true;
        var lastNum: ?u8 = null;
        var direction: ?bool = null;
        while (!newLine) : (newLine = f.read_space()) {
            const num = f.read_number(u8);
            if (lastNum) |l_num| {
                const diff = @as(i8, @intCast(num)) - @as(i8, @intCast(l_num));
                if (diff == 0 or @abs(diff) > 3) isSafe = false;
                const sign = diff > 0;
                if (direction) |d| {
                    if (sign != d) isSafe = false;
                } else direction = sign;
            }
            if (!isSafe) {
                if (std.mem.indexOf(u8, f.file_data, "\n")) |i| {
                    f.file_data = f.file_data[i + 1 ..];
                } else f.file_data = "";
                break;
            }

            lastNum = num;
        }

        if (isSafe) {
            numSafe += 1;
        }
    }

    return numSafe;
}
