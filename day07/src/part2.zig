const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    try aoc.main_with_bench(u64, .{gpa.allocator()}, solve);
}

fn solve(fd: aoc.FileData, ctx: struct { std.mem.Allocator }) u64 {
    const alloc = ctx[0];
    var f = fd;

    var count: u64 = 0;

    while (true) {
        const exp_result = f.read_number(u64);
        if (exp_result == 0) break;
        std.debug.assert(f.accept(":"));
        std.debug.assert(!f.read_space());

        var operands = std.ArrayListUnmanaged(u32){};
        defer operands.deinit(alloc);
        while (true) {
            const op = f.read_number(u32);
            operands.append(alloc, op) catch unreachable;
            if (f.read_space()) {
                break;
            }
        }
        const num_op_combinations = std.math.powi(usize, 3, operands.items.len - 1) catch unreachable;
        for (0..num_op_combinations + 1) |n| {
            var sum: u64 = operands.items[0];
            var cur_operator = n;
            for (operands.items[1..]) |next_operand| {
                switch (cur_operator % 3) {
                    0 => sum += next_operand,
                    1 => sum *= next_operand,
                    2 => sum = concat(sum, next_operand),
                    else => unreachable,
                }
                if (sum > exp_result) break;
                cur_operator /= 3;
            }
            if (sum == exp_result) {
                count += exp_result;
                break;
            }
        }
    }

    return count;
}

fn concat(a: u64, b: u64) u64 {
    var buf1: [64]u8 = undefined;
    var buf2: [32]u8 = undefined;
    const b1 = std.fmt.bufPrint(buf1[0 .. buf1.len / 2], "{d}", .{a}) catch unreachable;
    const b2 = std.fmt.bufPrint(&buf2, "{d}", .{b}) catch unreachable;
    @memcpy(buf1[b1.len..][0..b2.len], b2);
    return std.fmt.parseInt(u64, buf1[0 .. b1.len + b2.len], 10) catch unreachable;
}
