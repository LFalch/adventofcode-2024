const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    var gpa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer gpa.deinit();
    try aoc.main_with_bench(u32, .{gpa.allocator()}, solve);
}

const Coords = packed struct { x: u8, y: u8 };

fn solve(fd: aoc.FileData, ctx: struct { std.mem.Allocator }) u32 {
    const alloc = ctx[0];
    const grid = alloc.dupe(u8, fd.file_data) catch unreachable;
    defer alloc.free(grid);
    const w = std.mem.indexOfScalar(u8, grid, '\n').?;

    var total: u32 = 0;
    var visited = std.ArrayList(u16).initCapacity(alloc, 256) catch unreachable;
    defer visited.deinit();
    var nexts = std.ArrayList(Coords).initCapacity(alloc, 128) catch unreachable;
    defer nexts.deinit();

    for (0..w) |y| {
        for (0..w) |x| {
            const sx: u8 = @intCast(x);
            const sy: u8 = @intCast(y);
            const plot_type = grid[index(sx, sy, w).?];
            if (plot_type == '.') continue;
            var perimeter: u32 = 0;
            defer visited.clearRetainingCapacity();
            defer nexts.clearRetainingCapacity();
            nexts.append(.{ .x = sx, .y = sy }) catch unreachable;

            while (nexts.popOrNull()) |c| {
                const cs: u16 = @bitCast(c);
                if (std.mem.indexOfScalar(u16, visited.items, cs)) |_| continue;
                visited.append(cs) catch unreachable;

                if (check(c.x -% 1, c.y, w, grid, plot_type)) |p| nexts.append(p) catch unreachable else perimeter += 1;
                if (check(c.x + 1, c.y, w, grid, plot_type)) |p| nexts.append(p) catch unreachable else perimeter += 1;
                if (check(c.x, c.y -% 1, w, grid, plot_type)) |p| nexts.append(p) catch unreachable else perimeter += 1;
                if (check(c.x, c.y + 1, w, grid, plot_type)) |p| nexts.append(p) catch unreachable else perimeter += 1;
            }

            total += @as(u32, @intCast(visited.items.len)) * perimeter;

            for (visited.items) |cs| {
                const pos: Coords = @bitCast(cs);
                grid[index(pos.x, pos.y, w).?] = '.';
            }
        }
    }

    return total;
}

fn check(x: u8, y: u8, w: usize, grid: []const u8, c: u8) ?Coords {
    if (index(x, y, w)) |i| {
        if (grid[i] != c) return null;
        return .{ .x = x, .y = y };
    } else return null;
}

fn index(x: u8, y: u8, w: usize) ?usize {
    if (x < w and y < w) {
        return @as(usize, @intCast(x)) + @as(usize, @intCast(y)) * (w + 1);
    } else return null;
}
