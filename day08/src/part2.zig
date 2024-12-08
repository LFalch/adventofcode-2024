const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    try aoc.main_with_bench(u32, &arena, solve);
}

const Entry = struct { key: u8, value: std.BoundedArray(Pos, 4) };
const Pos = struct { i8, i8 };

fn solve(fd: aoc.FileData, arena: *std.heap.ArenaAllocator) u32 {
    const alloc = arena.allocator();
    defer _ = arena.reset(.retain_capacity);
    const w = std.mem.indexOf(u8, fd.file_data, "\n").? + 1;

    var antennae = std.MultiArrayList(Entry){};
    for (fd.file_data, 0..) |c, i| {
        if (std.ascii.isAlphanumeric(c)) {
            const index = b: {
                if (std.mem.indexOf(u8, antennae.items(.key), &.{c})) |index|
                    break :b index
                else {
                    antennae.append(alloc, .{ .key = c, .value = std.BoundedArray(Pos, 4){} }) catch unreachable;
                    break :b antennae.len - 1;
                }
            };
            antennae.items(.value)[index].append(.{ @intCast(i % w), @intCast(@divTrunc(i, w)) }) catch unreachable;
        }
    }

    var total: u32 = 0;

    const grid = alloc.dupe(u8, fd.file_data) catch unreachable;

    for (antennae.items(.value)) |value| {
        // all anteanne with same feq
        const antennas = value.slice();
        for (antennas, 0..) |a, i| {
            for (antennas[i + 1 ..]) |b| {
                const dx = b[0] - a[0];
                const dy = b[1] - a[1];

                var from_b = b;
                while (set_antinode(from_b[0], from_b[1], grid, w, &total)) {
                    from_b[0] += dx;
                    from_b[1] += dy;
                }
                var from_a = a;
                while (set_antinode(from_a[0], from_a[1], grid, w, &total)) {
                    from_a[0] -= dx;
                    from_a[1] -= dy;
                }
            }
        }
    }
    return total;
}

pub fn set_antinode(x: isize, y: isize, grid: []u8, w: usize, total: *u32) bool {
    if (x >= 0 and y >= 0 and x < w - 1 and y < w - 1) {
        const c = &grid[@as(usize, @intCast(x)) + @as(usize, @intCast(y)) * w];
        if (c.* != '#') {
            c.* = '#';
            total.* += 1;
        }
        return true;
    } else return false;
}
