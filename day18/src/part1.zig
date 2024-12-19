const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    try aoc.main_with_bench(u32, .{gpa.allocator()}, solve);
}

fn solve(fd: aoc.FileData, ctx: struct { std.mem.Allocator }) u32 {
    const alloc = ctx[0];
    const maze = Maze{
        .grid = alloc.alloc(u8, 71 * 71) catch unreachable,
    };
    defer alloc.free(maze.grid);
    @memset(maze.grid, '.');

    var f = fd;
    for (0..1024) |_| {
        const x: i8 = @intCast(f.read_number(u8));
        std.debug.assert(f.accept(","));
        const y: i8 = @intCast(f.read_number(u8));
        _ = f.read_space();
        maze.set(.{ .x = x, .y = y }, '#');
    }

    var length_map = std.AutoHashMap(Pos, u32).init(alloc);
    defer length_map.deinit();
    var queue = std.ArrayList(Entry).init(alloc);
    defer queue.deinit();
    queue.append(.{ .pos = .{ .x = 0, .y = 0 }, .length = 0 }) catch unreachable;

    while (queue.popOrNull()) |e| {
        length_map.put(e.pos, e.length) catch unreachable;

        for ([_]Dir{ .north, .east, .south, .west }) |dir| {
            const n = e.pos.add(dir);
            if (maze.isWall(n)) continue;
            const length = length_map.get(n);
            if (length == null or length.? > e.length + 1) {
                queue.append(.{ .pos = n, .length = e.length + 1 }) catch unreachable;
            }
        }
    }

    return length_map.get(.{ .x = 70, .y = 70 }).?;
}

const Dir = enum {
    east,
    south,
    west,
    north,
};
const Pos = struct {
    x: i8,
    y: i8,
    fn add(self: Pos, dir: Dir) Pos {
        return switch (dir) {
            .east => .{ .x = self.x + 1, .y = self.y },
            .south => .{ .x = self.x, .y = self.y + 1 },
            .west => .{ .x = self.x - 1, .y = self.y },
            .north => .{ .x = self.x, .y = self.y - 1 },
        };
    }
};
const Entry = struct {
    pos: Pos,
    length: u32,
};

const Maze = struct {
    grid: []u8,

    fn set(self: *const Maze, p: Pos, c: u8) void {
        const index = @as(usize, @intCast(p.x)) + @as(usize, @intCast(p.y)) * 71;
        self.grid[index] = c;
    }
    fn isWall(self: *const Maze, p: Pos) bool {
        if (p.x < 0 or p.y < 0 or p.x >= 71) return true;
        const index = @as(usize, @intCast(p.x)) + @as(usize, @intCast(p.y)) * 71;
        if (index >= (71 * 71)) return true;
        return self.grid[index] == '#';
    }
};
