const std = @import("std");
const aoc = @import("aoc");

fn next_ins(f: *aoc.FileData) ?enum { Do, Dont, Mul } {
    while (true) {
        const i = std.mem.indexOfAny(u8, f.file_data, "dm") orelse return null;

        if (std.mem.startsWith(u8, f.file_data[i..], "mul(")) {
            f.file_data = f.file_data[i + 4 ..];
            return .Mul;
        } else if (std.mem.startsWith(u8, f.file_data[i..], "do(")) {
            f.file_data = f.file_data[i + 3 ..];
            return .Do;
        } else if (std.mem.startsWith(u8, f.file_data[i..], "don't(")) {
            f.file_data = f.file_data[i + 6 ..];
            return .Dont;
        } else {
            f.file_data = f.file_data[i + 1 ..];
        }
    }
}

pub fn main() !void {
    var f = try aoc.read_input();
    const timer = aoc.Timer.start();

    var mul_enabled = true;
    var sum: u32 = 0;
    loop: while (next_ins(&f)) |i| {
        switch (i) {
            .Do => {
                if (f.file_data[0] != ')') continue :loop else {
                    f.file_data = f.file_data[1..];
                }
                mul_enabled = true;
            },
            .Dont => {
                if (f.file_data[0] != ')') continue :loop else {
                    f.file_data = f.file_data[1..];
                }
                mul_enabled = false;
            },
            .Mul => {
                const l = f.read_number(u16);
                if (f.file_data[0] != ',') continue :loop else {
                    f.file_data = f.file_data[1..];
                }
                const r = f.read_number(u16);
                if (f.file_data[0] != ')') continue :loop else {
                    f.file_data = f.file_data[1..];
                }
                if (mul_enabled) {
                    sum += @as(u32, l) * @as(u32, r);
                }
            },
        }
    }
    timer.stop();
    try std.io.getStdOut().writer().print("{d}\n", .{sum});
}
