const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    try aoc.main_with_bench(u32, .{gpa.allocator()}, solve);
}

fn solve(fd: aoc.FileData, ctx: struct { std.mem.Allocator }) u32 {
    _ = fd;
    _ = ctx;
    return 0;
}
