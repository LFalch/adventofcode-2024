const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    try aoc.main_with_bench(Pos, .{gpa.allocator()}, solve);
}

const initial_walls = 1024;
const size = 71;

fn solve(fd: aoc.FileData, ctx: struct { std.mem.Allocator }) Pos {
    const alloc = ctx[0];
    const maze = Maze{
        .grid = alloc.alloc(u8, size * size) catch unreachable,
    };
    defer alloc.free(maze.grid);
    @memset(maze.grid, '.');

    var f = fd;
    for (0..initial_walls) |_| {
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
    pathfind(&queue, &length_map, &maze);

    while (true) {
        const x: i8 = @intCast(f.read_number(u8));
        if (!f.accept(",")) break;
        const y: i8 = @intCast(f.read_number(u8));
        _ = f.read_space();
        const p = Pos{ .x = x, .y = y };
        maze.set(p, '#');

        {
            const length_to_new_wall = if (length_map.fetchRemove(p)) |kv| kv.value else continue;
            var new_edges = std.AutoArrayHashMap(Pos, void).init(alloc);
            defer new_edges.deinit();
            queue.append(.{ .pos = p, .length = length_to_new_wall }) catch unreachable;

            while (queue.popOrNull()) |e| {
                for ([_]Dir{ .north, .east, .south, .west }) |dir| {
                    const n = e.pos.add(dir);
                    if (length_map.get(n)) |l| {
                        if (l == e.length + 1) {
                            _ = length_map.remove(n);
                            queue.append(.{ .pos = n, .length = l }) catch unreachable;
                        } else {
                            new_edges.put(n, {}) catch unreachable;
                        }
                    }
                }
            }

            for (new_edges.keys()) |key| {
                if (length_map.get(key)) |length| {
                    queue.append(.{ .pos = key, .length = length }) catch unreachable;
                }
            }
        }

        pathfind(&queue, &length_map, &maze);
        const new_length = length_map.get(.{ .x = (size - 1), .y = (size - 1) });
        if (new_length == null) {
            return p;
        }
    }
    unreachable;
}

fn pathfind(queue: *std.ArrayList(Entry), length_map: *std.AutoHashMap(Pos, u32), maze: *const Maze) void {
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
    if (@import("builtin").mode == .Debug or @import("builtin").mode == .ReleaseSafe) {
        var p = Pos{ .x = size - 1, .y = size - 1 };
        if (length_map.get(p)) |start_length| {
            var l = start_length;
            while (l > 0) {
                l -= 1;
                for ([_]Dir{ .north, .east, .south, .west }) |dir| {
                    const n = p.add(dir);
                    if (length_map.get(n) == l) {
                        p = n;
                        maze.set(p, switch (dir) {
                            .north => 'v',
                            .east => '<',
                            .south => '^',
                            .west => '>',
                        });
                        break;
                    }
                } else {
                    break;
                }
            }
        }
    }
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
    pub fn format(
        self: Pos,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;

        try writer.print("{d},{d}", .{ self.x, self.y });
    }
};
const Entry = struct {
    pos: Pos,
    length: u32,
};

const Maze = struct {
    grid: []u8,

    fn set(self: *const Maze, p: Pos, c: u8) void {
        const index = @as(usize, @intCast(p.x)) + @as(usize, @intCast(p.y)) * size;
        self.grid[index] = c;
    }
    fn isWall(self: *const Maze, p: Pos) bool {
        if (p.x < 0 or p.y < 0 or p.x >= size) return true;
        const index = @as(usize, @intCast(p.x)) + @as(usize, @intCast(p.y)) * size;
        if (index >= (size * size)) return true;
        return self.grid[index] == '#';
    }
};
