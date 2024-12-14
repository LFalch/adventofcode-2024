const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    try aoc.main_with_bench(u32, .{gpa.allocator()}, solve);
}

const Robot = struct {
    x: u8,
    y: u8,
    vx: i8,
    vy: i8,
};

fn solve(fd: aoc.FileData, ctx: struct { std.mem.Allocator }) u32 {
    const alloc = ctx[0];
    var f = fd;

    var robots = std.ArrayList(Robot).init(alloc);
    defer robots.deinit();

    while (!f.is_done()) {
        std.debug.assert(f.accept("p="));
        const x = f.read_number(u8);
        std.debug.assert(f.accept(","));
        const y = f.read_number(u8);
        std.debug.assert(f.accept(" v="));
        const vx = f.read_number(i8);
        std.debug.assert(f.accept(","));
        const vy = f.read_number(i8);
        _ = f.read_space();
        std.debug.print("{d}, {d}  {d}, {d}\n", .{ x, y, vx, vy });
        robots.append(.{ .x = x, .y = y, .vx = vx, .vy = vy }) catch unreachable;
    }

    var n: u32 = 0;
    while (true) : (n += 1) {
        const grid = alloc.dupe(u8, ("." ** 101 ++ "\n") ** 103) catch unreachable;
        defer alloc.free(grid);
        for (robots.items) |*robot| {
            robot.x = @intCast(@mod(@as(i16, robot.x) + robot.vx, 101));
            robot.y = @intCast(@mod(@as(i16, robot.y) + robot.vy, 103));
            grid[robot.x + 102 * @as(u16, robot.y)] = '#';
        }
        std.debug.print("{d}:\n{s}\n", .{ n + 1, grid });
        _ = std.io.getStdIn().reader().readUntilDelimiterOrEof(grid, '\n') catch unreachable;
    }

    return n;
}
