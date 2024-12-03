const std = @import("std");
const aoc = @import("aoc");

var mem_buf: [16]u8 = undefined;

pub fn main() !void {
    var gpa = std.heap.FixedBufferAllocator.init(&mem_buf);

    try aoc.main_with_bench(u16, .{gpa.allocator()}, solve);
}

fn solve(fd: aoc.FileData, ctx: struct { std.mem.Allocator }) u16 {
    const alloc = ctx[0];
    var f = fd;

    var numSafe: u16 = 0;

    while (!f.is_done()) {
        var list = std.ArrayList(u8).init(alloc);
        defer list.deinit();

        var newLine = false;
        while (!newLine) : (newLine = f.read_space()) {
            list.append(f.read_number(u8)) catch unreachable;
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
    return numSafe;
}
