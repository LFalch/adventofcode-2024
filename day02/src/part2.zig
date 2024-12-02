const std = @import("std");
const aoc = @import("aoc");

var mem_buf: [2048]u8 = undefined;

pub fn main() !void {
    var gpa = std.heap.FixedBufferAllocator.init(&mem_buf);
    const alloc = gpa.allocator();

    var f = try aoc.read_input();
    const timer = aoc.Timer.start();

    var numSafe: u64 = 0;

    while (!f.is_done()) {
        var list = std.ArrayList(u8).init(alloc);
        defer list.deinit();

        var newLine = false;
        while (!newLine) : (newLine = f.read_space()) {
            try list.append(f.read_number(u8));
        }

        var unsafesRemoved: u8 = 0;
        var lastNum: ?u8 = null;
        var direction: ?bool = null;
        for (list.items) |num| {
            if (unsafesRemoved > 1) break;
            var isSafe = true;
            l: {
                if (lastNum) |l_num| {
                    const diff: i9 = @as(i9, num) - l_num;
                    if (@abs(diff) == 0 or @abs(diff) > 3) {
                        isSafe = false;
                        break :l;
                    }
                    const sign = diff > 0;
                    if (direction) |d| {
                        if (sign != d) {
                            isSafe = false;
                            break :l;
                        }
                    } else direction = sign;
                }
            }
            if (!isSafe) {
                unsafesRemoved += 1;
            } else {
                lastNum = num;
            }
        }
        if (unsafesRemoved > 1) {
            std.mem.reverse(u8, list.items);
            unsafesRemoved = 0;
            lastNum = null;
            direction = null;
            for (list.items) |num| {
                if (unsafesRemoved > 1) break;
                var isSafe = true;
                l: {
                    if (lastNum) |l_num| {
                        const diff: i9 = @as(i9, num) - l_num;
                        if (@abs(diff) == 0 or @abs(diff) > 3) {
                            isSafe = false;
                            break :l;
                        }
                        const sign = diff > 0;
                        if (direction) |d| {
                            if (sign != d) {
                                isSafe = false;
                                break :l;
                            }
                        } else direction = sign;
                    }
                }
                if (!isSafe) {
                    unsafesRemoved += 1;
                } else {
                    lastNum = num;
                }
            }
        }

        if (unsafesRemoved <= 1) {
            numSafe += 1;
        }
    }
    timer.stop();
    try std.io.getStdOut().writer().print("{d}\n", .{numSafe});
}
