const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    var gpa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer gpa.deinit();
    var pool: std.Thread.Pool = undefined;
    try pool.init(.{ .allocator = gpa.allocator() });
    defer pool.deinit();
    try aoc.main_with_bench(u64, &pool, solve);
}

const Equation = struct {
    result: u64,
    operands: std.BoundedArray(u16, 16),
};

fn solve(fd: aoc.FileData, pool: *std.Thread.Pool) u64 {
    var f = fd;

    var equations = std.BoundedArray(Equation, 1000){};

    var count = std.atomic.Value(u64).init(0);
    var wg = std.Thread.WaitGroup{};

    while (true) {
        var equation = equations.addOne() catch unreachable;
        const exp_result = f.read_number(u64);
        if (exp_result == 0) break;
        equation.result = exp_result;
        std.debug.assert(f.accept(":"));
        std.debug.assert(!f.read_space());

        equation.operands = std.BoundedArray(u16, 16){};
        while (true) {
            const op = f.read_number(u16);
            equation.operands.append(op) catch unreachable;
            if (f.read_space()) {
                break;
            }
        }
        pool.spawnWg(&wg, work, .{ equation, &count });
    }
    pool.waitAndWork(&wg);

    return count.load(.acquire);
}

fn work(equation: *Equation, count: *std.atomic.Value(u64)) void {
    const operands = equation.operands.slice();
    const exp_result = equation.result;

    const concat_op_places = @as(usize, 1) << @as(u5, @intCast(operands.len - 1));
    for (0..concat_op_places) |concat_place| {
        const arith_op_combinations = @as(usize, 1) << @as(u5, @intCast(operands.len - 1 - @popCount(concat_place)));
        for (0..arith_op_combinations) |arith_ops| {
            var sum: u64 = operands[0];
            var cur_arith = arith_ops;
            var cur_concat = concat_place;
            for (operands[1..]) |next_operand| {
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
                _ = count.fetchAdd(exp_result, .release);
                return;
            }
        }
    }
}

fn concat(a: u64, b: u64) u64 {
    const pow = std.math.powi(u64, 10, std.math.log10_int(b) + 1) catch unreachable;
    return a * pow + b;
}
