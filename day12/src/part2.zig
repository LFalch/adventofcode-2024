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
const Coords = packed struct { x: u8, y: u8 };
const VisitedEntry = struct { i: u16, v: Visited };

fn add(c: Coords, comptime dir: Visited) Coords {
    return switch (dir) {
        LEFT => .{ .x = c.x -% 1, .y = c.y },
        RIGHT => .{ .x = c.x + 1, .y = c.y },
        UP => .{ .x = c.x, .y = c.y -% 1 },
        DOWN => .{ .x = c.x, .y = c.y + 1 },
        else => @compileError("invalid direction"),
    };
}
fn neg(comptime dir: Visited) Visited {
    return switch (dir) {
        LEFT => RIGHT,
        RIGHT => LEFT,
        UP => DOWN,
        DOWN => UP,
        else => @compileError("invalid direction"),
    };
}
fn hat(comptime dir: Visited) Visited {
    return switch (dir) {
        RIGHT => UP,
        UP => LEFT,
        LEFT => DOWN,
        DOWN => RIGHT,
        else => @compileError("invalid direction"),
    };
}

fn solve(fd: aoc.FileData, ctx: struct { std.mem.Allocator }) u32 {
    const alloc = ctx[0];
    const grid = alloc.dupe(u8, fd.file_data) catch unreachable;
    defer alloc.free(grid);
    const w = std.mem.indexOfScalar(u8, grid, '\n').?;

    var total: u32 = 0;
    var visited = std.MultiArrayList(VisitedEntry){};
    defer visited.deinit(alloc);
    visited.setCapacity(alloc, 256) catch unreachable;
    var nexts = std.ArrayList(Coords).initCapacity(alloc, 128) catch unreachable;
    defer nexts.deinit();

    for (0..w) |y| {
        for (0..w) |x| {
            const s = Coords{ .x = @intCast(x), .y = @intCast(y) };
            const plot_type = grid[index(s, w).?];
            if (plot_type == '.') continue;
            var sides: u32 = 0;
            defer visited.resize(alloc, 0) catch unreachable;
            defer nexts.clearRetainingCapacity();
            nexts.append(s) catch unreachable;

            while (nexts.popOrNull()) |c| {
                if (std.mem.indexOfScalar(u16, visited.items(.i), @bitCast(c))) |_| continue;

                var v: Visited = 0;
                check(c, w, grid, plot_type, LEFT, &sides, &nexts, &visited, &v);
                check(c, w, grid, plot_type, RIGHT, &sides, &nexts, &visited, &v);
                check(c, w, grid, plot_type, DOWN, &sides, &nexts, &visited, &v);
                check(c, w, grid, plot_type, UP, &sides, &nexts, &visited, &v);

                visited.append(alloc, .{ .i = @bitCast(c), .v = v }) catch unreachable;
            }

            // mark as counted
            for (visited.items(.i)) |pos| {
                grid[index(@bitCast(pos), w).?] = '.';
            }

            const area: u32 = @intCast(visited.len);
            total += area * sides;
        }
    }

    return total;
}

fn check_edge(visited: *const std.MultiArrayList(VisitedEntry), i: Coords, comptime dir: Visited) bool {
    return if (std.mem.indexOfScalar(u16, visited.items(.i), @bitCast(i))) |in| visited.items(.v)[in] & dir != 0 else false;
}

fn check(c: Coords, w: usize, grid: []const u8, letter: u8, comptime dir: Visited, sides: *u32, nexts: *std.ArrayList(Coords), visited: *const std.MultiArrayList(VisitedEntry), v: *Visited) void {
    const neighbour = add(c, dir);
    if (index(neighbour, w)) |i| {
        if (grid[i] == letter) {
            nexts.append(neighbour) catch unreachable;
            return;
        }
    }

    v.* |= dir;
    var n: u2 = 0;
    if (check_edge(visited, add(c, hat(dir)), dir)) n += 1;
    if (check_edge(visited, add(c, neg(hat(dir))), dir)) n += 1;
    switch (n) {
        0 => sides.* += 1,
        2 => sides.* -= 1,
        else => {},
    }
}

fn index(c: Coords, w: usize) ?usize {
    if (c.x < w and c.y < w) {
        return @as(usize, @intCast(c.x)) + @as(usize, @intCast(c.y)) * (w + 1);
    } else return null;
}
