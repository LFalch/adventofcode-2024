const std = @import("std");
const aoc = @import("aoc");
const sol = @import("solution.zig");

pub fn main() !void {
    var gpa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer _ = gpa.deinit();
    try aoc.main_with_bench(usize, .{gpa.allocator()}, solve);
}

fn solve(fd: aoc.FileData, ctx: struct { std.mem.Allocator }) usize {
    _ = ctx[0];

    return sol.solve(fd, ctx[0], 75, 64 * 4096);
}
