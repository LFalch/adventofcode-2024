const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    var gpa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
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
        robots.append(.{ .x = x, .y = y, .vx = vx, .vy = vy }) catch unreachable;
    }

    for (0..100) |_| {
        for (robots.items) |*robot| {
            robot.x = @intCast(@mod(@as(i16, robot.x) + robot.vx, 101));
            robot.y = @intCast(@mod(@as(i16, robot.y) + robot.vy, 103));
        }
    }

    var q1: u32 = 0;
    var q2: u32 = 0;
    var q3: u32 = 0;
    var q4: u32 = 0;

    for (robots.items) |robot| {
        if (robot.x < 50) {
            if (robot.y < 51) {
                q1 += 1;
            } else if (robot.y > 51) {
                q2 += 1;
            }
        } else if (robot.x > 50) {
            if (robot.y < 51) {
                q3 += 1;
            } else if (robot.y > 51) {
                q4 += 1;
            }
        }
    }

    return q1 * q2 * q3 * q4;
}
