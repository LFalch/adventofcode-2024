const std = @import("std");
const aoc = @import("aoc");
const Table = @import("Table.zig");

pub fn main() !void {
    try aoc.main_with_bench(u32, {}, solve);
}

fn solve(fd: aoc.FileData, _: void) u32 {
    const table = Table.init(fd);

    var dx: i8 = 0;
    var dy: i8 = -1;

    const pi_start = std.mem.indexOf(u8, table.data, "^") orelse unreachable;
    var px: i16 = @intCast(pi_start % table.width);
    var py: i16 = @intCast(@divTrunc(pi_start, table.width));

    table.get_mut(@intCast(px), @intCast(py)).* = 'X';
    while (true) {
        const new_px = px + dx;
        const new_py = py + dy;

        if (!(new_px >= 0 and new_py >= 0 and new_px < table.width - 1 and new_py < table.width - 1)) {
            break;
        }

        const c = table.get_mut(@intCast(new_px), @intCast(new_py));
        if (c.* == '#') {
            dy = -dy;
            std.mem.swap(i8, &dx, &dy);
            continue;
        }
        px = new_px;
        py = new_py;
        c.* = 'X';
    }

    return @intCast(std.mem.count(u8, table.data, "X"));
}
