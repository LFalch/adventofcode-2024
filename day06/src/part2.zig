const std = @import("std");
const aoc = @import("aoc");
const Table = @import("Table.zig");

pub fn main() !void {
    var a = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer a.deinit();
    try aoc.main_with_bench(u32, a.allocator(), solve);
}

fn solve(fd: aoc.FileData, alloc: std.mem.Allocator) u32 {
    const table = Table.init(alloc, fd);
    defer table.deinit(alloc);

    const pi_start = std.mem.indexOf(u8, table.data, "^") orelse unreachable;
    const px_start: i16 = @intCast(pi_start % table.width);
    const py_start: i16 = @intCast(@divTrunc(pi_start, table.width));

    var sum: u32 = 0;

    var dx: i8 = 0;
    var dy: i8 = -1;
    var px: i16 = px_start;
    var py: i16 = py_start;

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
        if (c.* == '.') {
            const inner_table = table.copy(alloc);
            defer inner_table.deinit(alloc);
            inner_table.get_mut(@intCast(new_px), @intCast(new_py)).* = '#';
            if (travel(inner_table, px, py, dx, dy)) {
                sum += 1;
            }
            c.* = 'X';
        }
        px = new_px;
        py = new_py;
    }

    return sum;
}

fn travel(table: Table, px_start: i16, py_start: i16, dx_start: i8, dy_start: i8) bool {
    var dx: i8 = dx_start;
    var dy: i8 = dy_start;
    var px: i16 = px_start;
    var py: i16 = py_start;

    while (true) {
        const new_px = px + dx;
        const new_py = py + dy;

        if (!(new_px >= 0 and new_py >= 0 and new_px < table.width - 1 and new_py < table.width - 1)) {
            break;
        }

        const c = table.get(@intCast(new_px), @intCast(new_py));
        if (c == '#') {
            const d: u8 = if (dx == 0)
                if (dy == 1) 4 else 8
            else if (dx == 1) 1 else 2;

            const pc = table.get_mut(@intCast(px), @intCast(py));
            if (pc.* < 16) {
                if (pc.* & d != 0) return true else {
                    pc.* |= d;
                }
            } else pc.* = d;

            dy = -dy;
            std.mem.swap(i8, &dx, &dy);
            continue;
        }
        px = new_px;
        py = new_py;
    }
    return false;
}
