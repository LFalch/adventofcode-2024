const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    var gpa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer gpa.deinit();
    try aoc.main_with_bench(u32, .{gpa.allocator()}, solve);
}

const LEFT: Visited = 1;
const RIGHT: Visited = 2;
const UP: Visited = 4;
const DOWN: Visited = 8;
const Visited = u4;

fn solve(fd: aoc.FileData, ctx: struct { std.mem.Allocator }) u32 {
    const alloc = ctx[0];
    const grid = alloc.dupe(u8, fd.file_data) catch unreachable;
    defer alloc.free(grid);
    const w = std.mem.indexOfScalar(u8, grid, '\n').?;

    var total: u32 = 0;

    for (0..w) |y| {
        for (0..w) |x| {
            const sx: u8 = @intCast(x);
            const sy: u8 = @intCast(y);
            const plot_type = grid[index(sx, sy, w).?];
            if (plot_type == '.') continue;
            var area: u32 = 0;
            var sides: u32 = 0;
            var visited = std.AutoArrayHashMap(struct { u8, u8 }, Visited).init(alloc);
            defer visited.deinit();
            var nexts = std.ArrayList(struct { u8, u8 }).init(alloc);
            defer nexts.deinit();
            nexts.append(.{ sx, sy }) catch unreachable;

            while (nexts.popOrNull()) |next| {
                if (visited.get(next) != null) continue;
                var v: Visited = 0;

                const cx = next[0];
                const cy = next[1];
                area += 1;

                if (check(cx -% 1, cy, w, grid, plot_type)) |p| nexts.append(p) catch unreachable else {
                    v |= LEFT;
                    var n: u2 = 0;
                    if (check_edge(visited.get(.{ cx, cy + 1 }), LEFT)) n += 1;
                    if (check_edge(visited.get(.{ cx, cy -% 1 }), LEFT)) n += 1;
                    switch (n) {
                        0 => sides += 1,
                        2 => sides -= 1,
                        else => {},
                    }
                }
                if (check(cx + 1, cy, w, grid, plot_type)) |p| nexts.append(p) catch unreachable else {
                    v |= RIGHT;
                    var n: u2 = 0;
                    if (check_edge(visited.get(.{ cx, cy + 1 }), RIGHT)) n += 1;
                    if (check_edge(visited.get(.{ cx, cy -% 1 }), RIGHT)) n += 1;
                    switch (n) {
                        0 => sides += 1,
                        2 => sides -= 1,
                        else => {},
                    }
                }
                if (check(cx, cy -% 1, w, grid, plot_type)) |p| nexts.append(p) catch unreachable else {
                    v |= UP;
                    var n: u2 = 0;
                    if (check_edge(visited.get(.{ cx + 1, cy }), UP)) n += 1;
                    if (check_edge(visited.get(.{ cx -% 1, cy }), UP)) n += 1;
                    switch (n) {
                        0 => sides += 1,
                        2 => sides -= 1,
                        else => {},
                    }
                }
                if (check(cx, cy + 1, w, grid, plot_type)) |p| nexts.append(p) catch unreachable else {
                    v |= DOWN;
                    var n: u2 = 0;
                    if (check_edge(visited.get(.{ cx + 1, cy }), DOWN)) n += 1;
                    if (check_edge(visited.get(.{ cx -% 1, cy }), DOWN)) n += 1;
                    switch (n) {
                        0 => sides += 1,
                        2 => sides -= 1,
                        else => {},
                    }
                }
                visited.put(next, v) catch unreachable;
            }

            // mark as counted
            for (visited.keys()) |pos| {
                grid[index(pos[0], pos[1], w).?] = '.';
            }

            total += area * sides;
        }
    }

    return total;
}

fn check_edge(v: ?Visited, comptime dir: Visited) bool {
    return if (v) |i| i & dir != 0 else false;
}

fn check(x: u8, y: u8, w: usize, grid: []const u8, c: u8) ?struct { u8, u8 } {
    if (index(x, y, w)) |i| {
        if (grid[i] != c) return null;
        return .{ x, y };
    } else return null;
}

fn index(x: u8, y: u8, w: usize) ?usize {
    if (x < w and y < w) {
        return @as(usize, @intCast(x)) + @as(usize, @intCast(y)) * (w + 1);
    } else return null;
}
