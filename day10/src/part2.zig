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
                const score = check_trail_rating(f, w, @intCast(x), @intCast(y), alloc);
                total += score;
            }
        }
    }

    return total;
}

const Pos = struct { i8, i8 };
const Trail = std.BoundedArray(Pos, 10);

fn check_trail_rating(fd: aoc.FileData, w: usize, sx: i8, sy: i8, alloc: std.mem.Allocator) u32 {
    var next = std.ArrayList(Trail).initCapacity(alloc, 16) catch unreachable;
    defer next.deinit();
    var first_trail = Trail.init(1) catch unreachable;
    first_trail.set(0, .{ sx, sy });
    next.append(first_trail) catch unreachable;

    var score: u32 = 0;

    while (next.popOrNull()) |trail| {
        const ti = trail.len - 1;
        const th = '0' + @as(u8, @intCast(ti));
        const p = trail.get(ti);
        const this_h = fd.file_data[index(p[0], p[1], w).?];
        if (this_h == th) {
            if (this_h == '9') {
                score += 1;
                continue;
            }
            if (check(p[0] + 1, p[1], w, trail)) |t| next.append(t) catch unreachable;
            if (check(p[0] - 1, p[1], w, trail)) |t| next.append(t) catch unreachable;
            if (check(p[0], p[1] + 1, w, trail)) |t| next.append(t) catch unreachable;
            if (check(p[0], p[1] - 1, w, trail)) |t| next.append(t) catch unreachable;
        }
    }

    return score;
}

fn check(x: i8, y: i8, w: usize, trail: Trail) ?Trail {
    if (x >= 0 and y >= 0 and x < w - 1 and y < w - 1) {
        var nt = trail;
        for (trail.slice()) |t| {
            if (t[0] == x and t[1] == y) return null;
        }
        nt.append(.{ x, y }) catch unreachable;
        return nt;
    } else return null;
}

fn index(x: anytype, y: anytype, w: usize) ?usize {
    if (x >= 0 and y >= 0 and x < w - 1 and y < w - 1) {
        return @as(usize, @intCast(x)) + @as(usize, @intCast(y)) * w;
    } else return null;
}
