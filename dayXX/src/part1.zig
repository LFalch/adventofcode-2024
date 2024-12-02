const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    var gpa = std.heap.HeapAllocator.init();
    defer _ = gpa.deinit();

    var f = try aoc.read_input();
    // READ DATA
    const timer = aoc.Timer.start();
    // CALCULATE RESULT
    timer.stop();
    try std.io.getStdOut().writer().print("{d}\n", .{0});
}
