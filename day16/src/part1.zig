const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    try aoc.main_with_bench(u32, .{gpa.allocator()}, solve);
}

const MAXU32: u32 = std.math.maxInt(u32);

fn solve(fd: aoc.FileData, ctx: struct { std.mem.Allocator }) u32 {
    const alloc = ctx[0];
    const maze = Maze.new(fd);

    var cost_map = std.AutoHashMap(Pos, u32).init(alloc);
    defer cost_map.deinit();
    var queue = std.ArrayList(Entry).init(alloc);
    defer queue.deinit();
    queue.append(.{ .pos = maze.start, .dir = .east, .score = 0 }) catch unreachable;

    while (queue.popOrNull()) |e| {
        const gop = cost_map.getOrPut(e.pos) catch unreachable;
        gop.value_ptr.* = e.score;

        if (!maze.isWall(e.pos.add(e.dir)) and (cost_map.get(e.pos.add(e.dir)) orelse MAXU32) > e.score + 1)
            queue.append(.{ .pos = e.pos.add(e.dir), .dir = e.dir, .score = e.score + 1 }) catch unreachable;
        if (!maze.isWall(e.pos.add(e.dir.right())) and (cost_map.get(e.pos.add(e.dir.right())) orelse MAXU32) > e.score + 1001)
            queue.append(.{ .pos = e.pos.add(e.dir.right()), .dir = e.dir.right(), .score = e.score + 1001 }) catch unreachable;
        if (!maze.isWall(e.pos.add(e.dir.left())) and (cost_map.get(e.pos.add(e.dir.left())) orelse MAXU32) > e.score + 1001)
            queue.append(.{ .pos = e.pos.add(e.dir.left()), .dir = e.dir.left(), .score = e.score + 1001 }) catch unreachable;
    }

    return cost_map.get(maze.end).?;
}

const Dir = enum {
    east,
    south,
    west,
    north,

    fn right(self: Dir) Dir {
        return switch (self) {
            .east => .south,
            .south => .west,
            .west => .north,
            .north => .east,
        };
    }
    fn left(self: Dir) Dir {
        return switch (self) {
            .east => .north,
            .north => .west,
            .west => .south,
            .south => .east,
        };
    }
};
const Pos = struct {
    x: u8,
    y: u8,
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
    dir: Dir,
    score: u32,
};

const Maze = struct {
    start: Pos,
    end: Pos,
    grid: []const u8,
    w: u8,

    fn new(fd: aoc.FileData) Maze {
        const w = std.mem.indexOf(u8, fd.file_data, "\n").?;
        const grid = fd.file_data[0 .. (w + 1) * w];

        const si = std.mem.indexOfScalar(u8, grid, 'S').?;
        const ei = std.mem.indexOfScalar(u8, grid, 'E').?;

        return .{
            .grid = grid,
            .w = @intCast(w + 1),
            .start = .{ .x = @intCast(@rem(si, w + 1)), .y = @intCast(@divFloor(si, w + 1)) },
            .end = .{ .x = @intCast(@rem(ei, w + 1)), .y = @intCast(@divFloor(ei, w + 1)) },
        };
    }
    fn isWall(self: *const Maze, p: Pos) bool {
        return self.grid[p.x + p.y * @as(usize, self.w)] == '#';
    }
};
