const std = @import("std");
const aoc = @import("aoc");

fn readFile(fd: aoc.FileData, left: *std.ArrayList(i32), right: *std.ArrayList(i32)) !void {
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

const SolFn = *const fn (*std.ArrayList(i32), *std.ArrayList(i32)) i32;

pub fn do(f: SolFn) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    try aoc.main_with_bench(i32, .{ alloc, f }, solve);
}

fn solve(fd: aoc.FileData, ctx: struct { std.mem.Allocator, SolFn }) i32 {
    const alloc = ctx[0];
    const f = ctx[1];
    var left = std.ArrayList(i32).initCapacity(alloc, 1001) catch unreachable;
    defer left.deinit();
    var right = std.ArrayList(i32).initCapacity(alloc, 1001) catch unreachable;
    defer right.deinit();

    readFile(fd, &left, &right) catch unreachable;

    std.mem.sortUnstable(i32, left.items, {}, comptime std.sort.asc(i32));
    std.mem.sortUnstable(i32, right.items, {}, comptime std.sort.asc(i32));

    return f(&left, &right);
}
