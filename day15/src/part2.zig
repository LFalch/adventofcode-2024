const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    var gpa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer _ = gpa.deinit();
    try aoc.main_with_bench(u32, gpa.allocator(), solve);
}

fn solve(fd: aoc.FileData, alloc: std.mem.Allocator) u32 {
    var f = fd;

    const b = std.mem.indexOf(u8, f.file_data, "\n").?;
    const w = b * 2;
    const h = b;
    const grid = alloc.alloc(u8, (w + 1) * h) catch unreachable;
    defer alloc.free(grid);

    {
        var i: usize = 0;
        var j: usize = 0;
        while (i < grid.len) : ({
            i += 2;
            j += 1;
        }) {
            const c = f.file_data[j];
            if (f.file_data[j] == 'O') {
                grid[i] = '[';
                grid[i + 1] = ']';
            } else if (f.file_data[j] == '\n') {
                grid[i] = '\n';
                i -= 1;
            } else {
                grid[i] = c;
                grid[i + 1] = c;
            }
        }
    }

    f.file_data = f.file_data[(b + 1) * b ..];

    const si = std.mem.indexOf(u8, grid, "@").?;
    grid[si] = '.';
    grid[si + 1] = '.';
    const sx: i8 = @intCast(@rem(si, w + 1));
    const sy: i8 = @intCast(@divFloor(si, w + 1));

    var x = sx;
    var y = sy;

    for (f.file_data) |c| {
        var dx: i2 = 0;
        var dy: i2 = 0;
        switch (c) {
            '^' => dy = -1,
            '>' => dx = 1,
            'v' => dy = 1,
            '<' => dx = -1,
            '\n' => continue,
            else => unreachable,
        }

        var nx: i8 = x + dx;
        const ny: i8 = y + dy;
        switch (grid[index(nx, ny, w)]) {
            '[', ']' => {
                if (dy == 0) {
                    while (grid[index(nx, y, w)] == '[' or grid[index(nx, y, w)] == ']') {
                        nx = nx + dx;
                    }

                    if (grid[index(nx, y, w)] != '.') continue;
                    if (dx == 1) {
                        std.mem.copyBackwards(u8, grid[index(x + 2, y, w)..index(nx + 1, y, w)], grid[index(x + 1, y, w)..index(nx, y, w)]);
                    } else {
                        std.mem.copyForwards(u8, grid[index(nx, y, w)..index(x - 1, y, w)], grid[index(nx + 1, y, w)..index(x, y, w)]);
                    }

                    x = x + dx;
                    grid[index(x, y, w)] = '.';
                } else {
                    if (canPushVertically(grid, w, x, ny, dy)) {
                        pushVertically(grid, w, x, ny, dy);
                        y = ny;
                    }
                }
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
        if (c == '[') {
            total += @intCast(@rem(i, w + 1) + 100 * @divTrunc(i, w + 1));
        }
    }

    return total;
}

fn canPushVertically(grid: []const u8, w: usize, x: i8, y: i8, dy: i8) bool {
    if (grid[index(x, y, w)] == '[') {
        return canPushVertically(grid, w, x, y + dy, dy) and
            canPushVertically(grid, w, x + 1, y + dy, dy);
    } else if (grid[index(x, y, w)] == ']') {
        return canPushVertically(grid, w, x, y + dy, dy) and
            canPushVertically(grid, w, x - 1, y + dy, dy);
    } else {
        return grid[index(x, y, w)] == '.';
    }
}
fn pushVertically(grid: []u8, w: usize, x: i8, y: i8, dy: i8) void {
    if (grid[index(x, y, w)] == '[') {
        pushVertically(grid, w, x, y + dy, dy);
        grid[index(x, y, w)] = '.';
        grid[index(x, y + dy, w)] = '[';
        pushVertically(grid, w, x + 1, y + dy, dy);
        grid[index(x + 1, y, w)] = '.';
        grid[index(x + 1, y + dy, w)] = ']';
    } else if (grid[index(x, y, w)] == ']') {
        pushVertically(grid, w, x, y + dy, dy);
        grid[index(x, y, w)] = '.';
        grid[index(x, y + dy, w)] = ']';
        pushVertically(grid, w, x - 1, y + dy, dy);
        grid[index(x - 1, y, w)] = '.';
        grid[index(x - 1, y + dy, w)] = '[';
    }
}

fn index(x: i8, y: i8, w: usize) usize {
    return @as(usize, @intCast(x)) + @as(usize, @intCast(y)) * (w + 1);
}
