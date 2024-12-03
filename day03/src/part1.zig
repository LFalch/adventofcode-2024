const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    try aoc.main_with_bench(u32, {}, solve);
}

fn solve(fd: aoc.FileData, _: void) u32 {
    var f = fd;
    var sum: u32 = 0;
    while (std.mem.indexOf(u8, f.file_data, "mul(")) |i| {
        f.file_data = f.file_data[i + 4 ..];
        const l = f.read_number(u32);
        if (!f.accept(",")) continue;
        const r = f.read_number(u32);
        if (!f.accept(")")) continue;

        sum += l * r;
    }
    return sum;
}
