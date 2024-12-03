const std = @import("std");
const aoc = @import("aoc");

fn readFile(fd: aoc.FileData, left: *List, right: *List) !void {
    var data = fd;

    while (!data.is_done()) {
        const l = data.read_number(i32);
        std.debug.assert(!data.read_space());
        const r = data.read_number(i32);
        std.debug.assert(data.read_space());
        try left.append(l);
        try right.append(r);
    }
}

pub const List = std.BoundedArray(i32, 1001);
const SolFn = *const fn (*List, *List) i32;

pub fn do(f: SolFn) !void {
    try aoc.main_with_bench(i32, f, solve);
}

fn solve(fd: aoc.FileData, f: SolFn) i32 {
    var left = std.BoundedArray(i32, 1001).init(0) catch unreachable;
    var right = std.BoundedArray(i32, 1001).init(0) catch unreachable;

    readFile(fd, &left, &right) catch unreachable;

    std.mem.sortUnstable(i32, left.slice(), {}, comptime std.sort.asc(i32));
    std.mem.sortUnstable(i32, right.slice(), {}, comptime std.sort.asc(i32));

    return f(&left, &right);
}
