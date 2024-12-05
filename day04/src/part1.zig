const std = @import("std");
const aoc = @import("aoc");
const Table = @import("Table.zig");

pub fn main() !void {
    try aoc.main_with_bench(u32, {}, solve);
}

fn solve(fd: aoc.FileData, _: void) u32 {
    const table = Table.init(fd);
    const width = table.width - 1;

    var count: u32 = 0;

    // horizontal
    count += @intCast(std.mem.count(u8, table.data, "XMAS"));
    count += @intCast(std.mem.count(u8, table.data, "SAMX"));
    // vertical
    for (0..width) |x| {
        var xmas: u2 = 0;
        var samx: u2 = 0;

        for (0..width) |y| {
            xmasamx(table.get(x, y), &xmas, &samx, &count);
        }
    }
    // diagonal
    for (4..width + width - 1 - 2) |n| {
        const start_x = if (n < width) 0 else n - width;
        const start_y = if (n < width) width - n else 0;

        var xmas: u2 = 0;
        var samx: u2 = 0;

        var x = start_x;
        var y = start_y;
        while (x < width and y < width) : ({
            x += 1;
            y += 1;
        }) {
            xmasamx(table.get(x, y), &xmas, &samx, &count);
        }
    }
    // diagonal 2
    for (3..width + width - 1 - 3) |n| {
        const start_x = if (n < width) 0 else n - width + 1;
        const start_y = if (n < width) n else width - 1;

        var xmas: u2 = 0;
        var samx: u2 = 0;

        var x = start_x;
        var y = start_y;
        while (x < width and y < width) : ({
            x += 1;
            y -%= 1;
        }) {
            xmasamx(table.get(x, y), &xmas, &samx, &count);
        }
    }

    return count;
}

inline fn xmasamx(c: u8, xmas: *u2, samx: *u2, count: *u32) void {
    switch (c) {
        'X' => {
            xmas.* = 1;
            if (samx.* == 3) count.* += 1;
            samx.* = 0;
        },
        'M' => {
            if (xmas.* == 1) xmas.* = 2 else xmas.* = 0;
            if (samx.* == 2) samx.* = 3 else samx.* = 0;
        },
        'A' => {
            if (samx.* == 1) samx.* = 2 else samx.* = 0;
            if (xmas.* == 2) xmas.* = 3 else xmas.* = 0;
        },
        'S' => {
            samx.* = 1;
            if (xmas.* == 3) count.* += 1;
            xmas.* = 0;
        },
        else => unreachable,
    }
}
