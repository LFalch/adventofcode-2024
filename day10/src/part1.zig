const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    var gpa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer _ = gpa.deinit();
    try aoc.main_with_bench(u32, .{gpa.allocator()}, solve);
}

fn solve(fd: aoc.FileData, ctx: struct { std.mem.Allocator }) u32 {
    const alloc = ctx[0];
    const f = fd;

    const w = std.mem.indexOf(u8, f.file_data, "\n").? + 1;

    var total: u32 = 0;

    for (0..w - 1) |y| {
        for (0..w - 1) |x| {
            const i = index(x, y, w).?;
            if (f.file_data[i] == '0') {
                total += check_trail_score(f, w, @intCast(x), @intCast(y), alloc);
            }
        }
    }

    return total;
}

const Pos = struct { i8, i8 };
const PosWithHeight = struct { i8, i8, u8 };

fn check_trail_score(fd: aoc.FileData, w: usize, sx: i8, sy: i8, alloc: std.mem.Allocator) u32 {
    var visited = std.ArrayList(Pos).initCapacity(alloc, 32) catch unreachable;
    defer visited.deinit();
    var next = std.ArrayList(PosWithHeight).initCapacity(alloc, 16) catch unreachable;
    defer next.deinit();
    next.append(.{ sx, sy, '0' }) catch unreachable;

    var score: u32 = 0;

    while (next.popOrNull()) |p| {
        const this_h = fd.file_data[index(p[0], p[1], w).?];
        if (this_h == p[2]) {
            visited.append(.{ p[0], p[1] }) catch unreachable;
            if (this_h == '9') {
                score += 1;
                continue;
            }
            const nh = this_h + 1;
            if (check(p[0] + 1, p[1], nh, w, &visited)) |n| next.append(n) catch unreachable;
            if (check(p[0] - 1, p[1], nh, w, &visited)) |n| next.append(n) catch unreachable;
            if (check(p[0], p[1] + 1, nh, w, &visited)) |n| next.append(n) catch unreachable;
            if (check(p[0], p[1] - 1, nh, w, &visited)) |n| next.append(n) catch unreachable;
        }
    }

    return score;
}

fn check(x: i8, y: i8, h: u8, w: usize, visited: *const std.ArrayList(Pos)) ?PosWithHeight {
    if (x >= 0 and y >= 0 and x < w - 1 and y < w - 1) {
        for (visited.items) |p| {
            if (p[0] == x and p[1] == y) return null;
        }
        return .{ x, y, h };
    } else return null;
}

fn index(x: anytype, y: anytype, w: usize) ?usize {
    if (x >= 0 and y >= 0 and x < w - 1 and y < w - 1) {
        return @as(usize, @intCast(x)) + @as(usize, @intCast(y)) * w;
    } else return null;
}
