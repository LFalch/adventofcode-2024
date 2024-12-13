const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    try aoc.main_with_bench(u32, {}, solve);
}

fn solve(fd: aoc.FileData, _: void) u32 {
    var f = fd;

    var total: u32 = 0;

    while (!f.is_done()) {
        std.debug.assert(f.accept("Button A: X+"));
        const a_x = f.read_number(u32);
        std.debug.assert(f.accept(", Y+"));
        const a_y = f.read_number(u32);
        std.debug.assert(f.accept("\nButton B: X+"));
        const b_x = f.read_number(u32);
        std.debug.assert(f.accept(", Y+"));
        const b_y = f.read_number(u32);
        std.debug.assert(f.accept("\nPrize: X="));
        const ex = f.read_number(u32);
        std.debug.assert(f.accept(", Y="));
        const ey = f.read_number(u32);
        std.debug.assert(f.read_space());

        const lcm = a_x * @divExact(a_y, std.math.gcd(a_x, a_y));

        const xm = @divExact(lcm, a_x);
        const ym = @divExact(lcm, a_y);

        const b = std.math.divExact(i64, @as(i64, xm * ex) - ym * ey, @as(i64, xm * b_x) - ym * b_y) catch continue;
        const a = std.math.divExact(i64, @as(i64, ey) - b_y * b, a_y) catch continue;

        total += @intCast(3 * a + b);
    }

    return total;
}
