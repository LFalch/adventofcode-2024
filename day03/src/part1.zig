const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    var f = try aoc.read_input();
    const timer = aoc.Timer.start();
    var sum: u32 = 0;
    while (std.mem.indexOf(u8, f.file_data, "mul(")) |i| {
        f.file_data = f.file_data[i + 4 ..];
        const l = f.read_number(u16);
        if (f.file_data[0] != ',') continue else {
            f.file_data = f.file_data[1..];
        }
        const r = f.read_number(u16);
        if (f.file_data[0] != ')') continue else {
            f.file_data = f.file_data[1..];
        }

        sum += @as(u32, l) * @as(u32, r);
    }
    timer.stop();
    try std.io.getStdOut().writer().print("{d}\n", .{sum});
}
