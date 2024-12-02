const std = @import("std");
const read_num = @import("root.zig").read_num;

pub fn main() !void {
    const f = try std.fs.cwd().openFile("input.txt", .{ .mode = .read_only });
    defer f.close();
    var buf_reader = std.io.bufferedReader(f.reader());
    const reader = buf_reader.reader();

    var numSafe: u64 = 0;

    big: while (true) {
        var isSafe = true;
        var lastNum: ?u8 = null;
        var direction: ?bool = null;
        while (read_num(reader) catch |e| if (e == error.EndOfStream) break :big else return e) |num| {
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
    try std.io.getStdOut().writer().print("{d}\n", .{numSafe});
}
