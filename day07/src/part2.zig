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
        const concat_op_places = @as(usize, 1) << @as(u5, @intCast(operands.items.len - 1));
        outer: for (0..concat_op_places) |concat_place| {
            const arith_op_combinations = @as(usize, 1) << @as(u5, @intCast(operands.items.len - 1 - @popCount(concat_place)));
            for (0..arith_op_combinations) |arith_ops| {
                var sum: u64 = operands.items[0];
                var cur_arith = arith_ops;
                var cur_concat = concat_place;
                for (operands.items[1..]) |next_operand| {
                    if (cur_concat & 1 != 0) {
                        sum = concat(sum, next_operand);
                    } else {
                        switch (cur_arith & 1) {
                            0 => sum += next_operand,
                            1 => sum *= next_operand,
                            else => unreachable,
                        }
                        cur_arith >>= 1;
                    }
                    cur_concat >>= 1;
                    if (sum > exp_result) break;
                }
                if (sum == exp_result) {
                    count += exp_result;
                    break :outer;
                }
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
