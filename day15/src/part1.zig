const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    var gpa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer _ = gpa.deinit();
    try aoc.main_with_bench(u32, gpa.allocator(), solve);
}

fn solve(fd: aoc.FileData, alloc: std.mem.Allocator) u32 {
    var f = fd;

    const w = std.mem.indexOf(u8, f.file_data, "\n").?;
    const grid = alloc.dupe(u8, f.file_data[0 .. (w + 1) * w]) catch unreachable;
    defer alloc.free(grid);
    f.file_data = f.file_data[(w + 1) * w ..];

    const si = std.mem.indexOf(u8, grid, "@").?;
    grid[si] = '.';
    const sx: i8 = @intCast(@rem(si, w + 1));
    const sy: i8 = @intCast(@divFloor(si, w + 1));

    var x = sx;
    var y = sy;

    for (f.file_data) |c| {
        var dx: i2 = 0;
        var dy: i2 = 0;
        switch (c) {
            '^' => {
                dy = -1;
            },
            '>' => {
                dx = 1;
            },
            'v' => {
                dy = 1;
            },
            '<' => {
                dx = -1;
            },
            '\n' => continue,
            else => unreachable,
        }

        var nx: i8 = x + dx;
        var ny: i8 = y + dy;
        switch (grid[index(nx, ny, w)]) {
            'O' => {
                while (grid[index(nx, ny, w)] == 'O') {
                    nx = nx + dx;
                    ny = ny + dy;
                }

                if (grid[index(nx, ny, w)] != '.') continue;
                grid[index(nx, ny, w)] = 'O';

                x = x + dx;
                y = y + dy;

                grid[index(x, y, w)] = '.';
            },
            '.' => {
                x = nx;
                y = ny;
            },
            else => {},
        }
    }

    var total: u32 = 0;

    for (grid, 0..) |c, i| {
        if (c == 'O') {
            total += @intCast(@rem(i, w + 1) + 100 * @divTrunc(i, w + 1));
        }
    }

    return total;
}

fn index(nx: i8, ny: i8, w: usize) usize {
    return @as(usize, @intCast(nx)) + @as(usize, @intCast(ny)) * (w + 1);
}
