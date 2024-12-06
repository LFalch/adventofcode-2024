const std = @import("std");
const aoc = @import("aoc");
const Table = @import("Table.zig");

pub fn main() !void {
    try aoc.main_with_bench(u32, {}, solve);
}

fn solve(fd: aoc.FileData, _: void) u32 {
    const table = Table.init(fd);

    const pi_start = std.mem.indexOf(u8, table.data, "^") orelse unreachable;
    const px: i16 = @intCast(pi_start % table.width);
    const py: i16 = @intCast(@divTrunc(pi_start, table.width));

    var sum: u32 = 0;

    for (0..table.width - 1) |y| {
        for (0..table.width - 1) |x| {
            const c = table.get_mut(x, y);
            if (c.* == '.') {
                c.* = '#';
                if (travel(table, px, py)) {
                    sum += 1;
                }
                c.* = '.';
            }
        }
    }

    return sum;
}

fn dir_entry(px: u32, py: u32, dx: i8, dy: i8) u34 {
    const d: u34 = if (dx == 0)
        if (dy == 1) 2 << 32 else 3 << 32
    else if (dx == 1) 0 << 32 else 1 << 32;
    const p = (px << 16) | py;
    return d | @as(u34, p);
}

fn travel(table: Table, px_start: i16, py_start: i16) bool {
    var dx: i8 = 0;
    var dy: i8 = -1;
    var px: i16 = px_start;
    var py: i16 = py_start;

    var list = std.BoundedArray(u34, 1024).init(0) catch unreachable;

    while (true) {
        const new_px = px + dx;
        const new_py = py + dy;

        if (!(new_px >= 0 and new_py >= 0 and new_px < table.width - 1 and new_py < table.width - 1)) {
            break;
        }

        const c = table.get(@intCast(new_px), @intCast(new_py));
        if (c == '#') {
            const entry = dir_entry(@intCast(px), @intCast(py), dx, dy);
            if (std.mem.indexOfScalar(u34, list.slice(), entry)) |_| {
                return true;
            }

            list.append(entry) catch unreachable;
            dy = -dy;
            std.mem.swap(i8, &dx, &dy);
            continue;
        }
        px = new_px;
        py = new_py;
    }
    return false;
}
