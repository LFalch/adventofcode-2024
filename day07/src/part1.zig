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
        for (0..1 + @as(usize, 1) << @as(u5, @intCast(operands.items.len - 1))) |n| {
            var sum: u64 = operands.items[0];
            var cur_operator = n;
            for (operands.items[1..]) |next_operand| {
                if ((cur_operator & 1) == 0) {
                    sum += next_operand;
                } else {
                    sum *= next_operand;
                }
                if (sum > exp_result) break;
                cur_operator >>= 1;
            }
            if (sum == exp_result) {
                count += exp_result;
                break;
            }
        }
    }

    return count;
}
