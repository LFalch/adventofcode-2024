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

    var dx: i8 = 0;
    var dy: i8 = -1;

    const pi_start = std.mem.indexOf(u8, table.data, "^") orelse unreachable;
    var px: i16 = @intCast(pi_start % table.width);
    var py: i16 = @intCast(@divTrunc(pi_start, table.width));

    var count: u32 = 1;
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
        if (c.* != 'X') {
            count += 1;
            c.* = 'X';
        }
    }

    return count;
}
