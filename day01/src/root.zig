const std = @import("std");

var buf: [4096]u8 = undefined;

fn readFile(left: *std.ArrayList(i64), right: *std.ArrayList(i64)) !void {
    const f = try std.fs.cwd().openFile("input.txt", .{ .mode = .read_only });
    defer f.close();
    var reader = std.io.bufferedReader(f.reader());

    while (true) {
        const line = reader.reader().readUntilDelimiter(&buf, '\n') catch |e| switch (e) {
            error.EndOfStream => break,
            else => return e,
        };
        const l = try std.fmt.parseInt(i64, line[0..5], 10);
        const r = try std.fmt.parseInt(i64, line[8 .. 8 + 5], 10);
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
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("{d}\n", .{sum});
    try bw.flush();
}
