const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    try aoc.main_with_bench(u32, .{gpa.allocator()}, solve);
}

const MAXU32: u32 = std.math.maxInt(u32);

fn meow(visited: *const std.AutoHashMap(Vec, u32), pos: Pos, dir: Dir, score: u32) ?Entry {
    const entry = .{ .pos = pos, .dir = dir, .score = score };
    if (visited.get(pos.with(dir))) |cur_score| {
        return if (cur_score > score) entry else null;
    } else {
        return entry;
    }
}

fn solve(fd: aoc.FileData, ctx: struct { std.mem.Allocator }) u32 {
    const alloc = ctx[0];
    const maze = Maze.new(fd);

    var cost_map = std.AutoHashMap(Vec, u32).init(alloc);
    defer cost_map.deinit();
    var min_score = MAXU32;
    {
        var queue = std.ArrayList(Entry).init(alloc);
        defer queue.deinit();
        queue.append(.{ .pos = maze.start, .dir = .east, .score = 0 }) catch unreachable;

        while (queue.popOrNull()) |e| {
            cost_map.put(e.pos.with(e.dir), e.score) catch unreachable;
            if (std.meta.eql(e.pos, maze.end))
                min_score = @min(e.score, min_score);

            if (!maze.isWall(e.pos.add(e.dir))) if (meow(&cost_map, e.pos.add(e.dir), e.dir, e.score + 1)) |ent|
                queue.append(ent) catch unreachable;
            if (!maze.isWall(e.pos.add(e.dir.right()))) if (meow(&cost_map, e.pos, e.dir.right(), e.score + 1000)) |ent|
                queue.append(ent) catch unreachable;
            if (!maze.isWall(e.pos.add(e.dir.left()))) if (meow(&cost_map, e.pos, e.dir.left(), e.score + 1000)) |ent|
                queue.append(ent) catch unreachable;
        }
    }
    var queue = std.ArrayList(Entry).init(alloc);
    defer queue.deinit();
    queue.append(.{ .pos = maze.end, .dir = .east, .score = cost_map.get(maze.end.with(.east)).? }) catch unreachable;
    queue.append(.{ .pos = maze.end, .dir = .south, .score = cost_map.get(maze.end.with(.south)).? }) catch unreachable;
    queue.append(.{ .pos = maze.end, .dir = .west, .score = cost_map.get(maze.end.with(.west)).? }) catch unreachable;
    queue.append(.{ .pos = maze.end, .dir = .north, .score = cost_map.get(maze.end.with(.north)).? }) catch unreachable;

    {
        var i: usize = 0;
        while (i < queue.items.len) {
            if (queue.items[i].score != min_score) {
                _ = queue.swapRemove(i);
            } else i += 1;
        }
    }

    var visited = std.AutoArrayHashMap(Pos, void).init(alloc);
    defer visited.deinit();

    while (queue.popOrNull()) |e| {
        visited.put(e.pos, {}) catch unreachable;

        if (e.score == 0) continue;
        const back = e.pos.add(e.dir.not());
        if (!maze.isWall(back) and cost_map.get(back.with(e.dir)) == e.score - 1)
            queue.append(.{ .pos = back, .dir = e.dir, .score = e.score - 1 }) catch unreachable;

        if (e.score < 1000) continue;
        if (cost_map.get(e.pos.with(e.dir.left())) == e.score - 1000)
            queue.append(.{ .pos = e.pos, .dir = e.dir.left(), .score = e.score - 1000 }) catch unreachable;
        if (cost_map.get(e.pos.with(e.dir.right())) == e.score - 1000)
            queue.append(.{ .pos = e.pos, .dir = e.dir.right(), .score = e.score - 1000 }) catch unreachable;
    }

    return @intCast(visited.count());
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
    fn not(self: Dir) Dir {
        return switch (self) {
            .east => .west,
            .north => .south,
            .west => .east,
            .south => .north,
        };
    }
};
const Vec = struct {
    pos: Pos,
    dir: Dir,
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
    fn with(pos: Pos, dir: Dir) Vec {
        return .{
            .pos = pos,
            .dir = dir,
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
