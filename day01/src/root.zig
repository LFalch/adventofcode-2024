const std = @import("std");
const aoc = @import("aoc");

fn readFile(left: *std.ArrayList(i64), right: *std.ArrayList(i64)) !void {
    var data = try aoc.read_input();

    while (!data.is_done()) {
        const l = data.read_number(i64);
        std.debug.assert(!data.read_space());
        const r = data.read_number(i64);
        std.debug.assert(data.read_space());
        try left.append(l);
        try right.append(r);
    }
}

pub fn do(f: anytype) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var left = std.ArrayList(i64).init(alloc);
    defer left.deinit();
    var right = std.ArrayList(i64).init(alloc);
    defer right.deinit();

    try readFile(&left, &right);

    std.mem.sort(i64, left.items, {}, comptime std.sort.asc(i64));
    std.mem.sort(i64, right.items, {}, comptime std.sort.asc(i64));

    const sum = f(&left, &right);

    const stdout_file = std.io.getStdOut().writer();

    try stdout_file.print("{d}\n", .{sum});
}
