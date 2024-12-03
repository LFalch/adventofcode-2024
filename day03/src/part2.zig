const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    try aoc.main_with_bench(u32, {}, solve);
}

fn solve(fd: aoc.FileData, _: void) u32 {
    var f = fd;

    var mul_enabled = true;
    var sum: u32 = 0;
    while (true) {
        if (mul_enabled) {
            const i = std.mem.indexOfAny(u8, f.file_data, "dm") orelse break;
            f.file_data = f.file_data[i..];

            if (f.accept("mul(")) {
                const l = f.read_number(u16);
                if (!f.accept(",")) continue;
                const r = f.read_number(u16);
                if (!f.accept(")")) continue;
                sum += @as(u32, l) * @as(u32, r);
            } else if (f.accept("don't()")) {
                mul_enabled = false;
            } else {
                f.file_data = f.file_data[1..];
            }
        } else {
            const needle = "do()";
            const i = std.mem.indexOf(u8, f.file_data, needle) orelse break;
            f.file_data = f.file_data[i + needle.len ..];
            mul_enabled = true;
        }
    }
    return sum;
}
