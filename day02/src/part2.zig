const std = @import("std");

var lineDoneNext = false;

fn read_num(reader: anytype) !?u8 {
    if (lineDoneNext) {
        lineDoneNext = false;
        return null;
    }

    var buf: [128]u8 = undefined;
    var i: usize = 0;

    while (true) {
        const b = try reader.readByte();

        switch (b) {
            '\n' => {
                lineDoneNext = true;
                break;
            },
            ' ' => break,
            else => {
                buf[i] = b;
                i += 1;
            },
        }
    }
    return try std.fmt.parseInt(u8, buf[0..i], 10);
}

var mem_buf: [2048]u8 = undefined;

pub fn main() !void {
    var gpa = std.heap.FixedBufferAllocator.init(&mem_buf);
    const alloc = gpa.allocator();

    const f = try std.fs.cwd().openFile("input.txt", .{ .mode = .read_only });
    defer f.close();
    var buf_reader = std.io.bufferedReader(f.reader());
    const reader = buf_reader.reader();

    var numSafe: u64 = 0;

    big: while (true) {
        var list = std.ArrayList(u8).init(alloc);
        defer list.deinit();
        while (read_num(reader) catch |e| if (e == error.EndOfStream) break :big else return e) |num| {
            try list.append(num);
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
    try std.io.getStdOut().writer().print("{d}\n", .{numSafe});
}
