const std = @import("std");
const aoc = @import("aoc");

fn readFile(left: *std.ArrayList(i32), right: *std.ArrayList(i32)) !void {
    var data = try aoc.read_input();

    while (!data.is_done()) {
        const l = data.read_number(i32);
        std.debug.assert(!data.read_space());
        const r = data.read_number(i32);
        std.debug.assert(data.read_space());
        try left.append(l);
        try right.append(r);
    }
}

pub fn do(f: anytype) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var left = try std.ArrayList(i32).initCapacity(alloc, 1001);
    defer left.deinit();
    var right = try std.ArrayList(i32).initCapacity(alloc, 1001);
    defer right.deinit();

    try readFile(&left, &right);

    const timer = aoc.Timer.start();

    std.mem.sortUnstable(i32, left.items, {}, comptime std.sort.asc(i32));
    std.mem.sortUnstable(i32, right.items, {}, comptime std.sort.asc(i32));

    const sum = f(&left, &right);

    timer.stop();

    const stdout_file = std.io.getStdOut().writer();
    try stdout_file.print("{d}\n", .{sum});
}
