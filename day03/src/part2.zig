const std = @import("std");
const aoc = @import("aoc");

fn next_ins(f: *aoc.FileData) ?enum { Do, Dont, Mul } {
    while (true) {
        const i = std.mem.indexOfAny(u8, f.file_data, "dm") orelse return null;
        f.file_data = f.file_data[i..];

        if (f.accept("mul(")) {
            return .Mul;
        } else if (f.accept("do(")) {
            return .Do;
        } else if (f.accept("don't(")) {
            return .Dont;
        } else {
            f.file_data = f.file_data[1..];
        }
    }
}

pub fn main() !void {
    try aoc.main_with_bench(u32, {}, solve);
}

fn solve(fd: aoc.FileData, _: void) u32 {
    var f = fd;

    var mul_enabled = true;
    var sum: u32 = 0;
    loop: while (next_ins(&f)) |i| {
        switch (i) {
            .Do => {
                if (!f.accept(")")) continue :loop;
                mul_enabled = true;
            },
            .Dont => {
                if (!f.accept(")")) continue :loop;
                mul_enabled = false;
            },
            .Mul => {
                const l = f.read_number(u16);
                if (!f.accept(",")) continue :loop;
                const r = f.read_number(u16);
                if (!f.accept(")")) continue :loop;
                if (mul_enabled) {
                    sum += @as(u32, l) * @as(u32, r);
                }
            },
        }
    }
    return sum;
}
