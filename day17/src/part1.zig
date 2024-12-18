const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    var gpa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer _ = gpa.deinit();
    try aoc.main_with_bench(u64, gpa.allocator(), solve);
}

fn solve(fd: aoc.FileData, alloc: std.mem.Allocator) u64 {
    var f = fd;

    std.debug.assert(f.accept("Register A: "));
    var reg_a = f.read_number(u64);
    std.debug.assert(f.accept("\nRegister B: "));
    var reg_b = f.read_number(u64);
    std.debug.assert(f.accept("\nRegister C: "));
    var reg_c = f.read_number(u64);

    _ = f.read_space();
    std.debug.assert(f.accept("Program: "));
    var program = std.ArrayList(u3).init(alloc);
    defer program.deinit();

    while (true) {
        const n: u3 = @intCast(f.read_number(u8));
        program.append(n) catch unreachable;
        if (!f.accept(",")) break;
    }

    var pc: u8 = 0;

    while (pc < program.items.len) {
        const opcode = program.items[pc];
        const operand = program.items[pc + 1];
        pc += 2;

        const combo = switch (operand) {
            0...3 => operand,
            4 => reg_a,
            5 => reg_b,
            6 => reg_c,
            7 => undefined,
        };

        switch (opcode) {
            // adv
            0 => reg_a = reg_a >> std.math.lossyCast(u6, combo),
            // bdv
            6 => reg_b = reg_a >> std.math.lossyCast(u6, combo),
            // cdv
            7 => reg_c = reg_a >> std.math.lossyCast(u6, combo),
            // bxl
            1 => reg_b ^= operand,
            // bst
            2 => reg_b = combo & 7,
            // jnz
            3 => if (reg_a != 0) {
                pc = operand;
            },
            // bxc
            4 => reg_b ^= reg_c,
            // out
            5 => std.debug.print("{d},", .{combo & 7}),
        }
    }
    std.debug.print("\n", .{});
    program_hc(51571418, 0, 0);

    return 0;
}

fn program_hc(a: u64, b: u64, c: u64) void {
    var ra: u64 = a;
    var rb: u64 = b;
    var rc: u64 = c;
    while (ra != 0) {
        // bst A    2 4
        rb = ra & 7;
        // bxl 1    1 1
        rb ^= 1;
        // cdv B    7 5
        rc = ra >> std.math.lossyCast(u6, rb);
        // adv 3    0 3
        ra = ra >> 3;
        // bxl 4    1 4
        rb ^= 4;
        // bxc (5)  4 5
        rb ^= rc;
        // out B    5 5
        std.debug.print("{d},", .{rb & 7});
    } // jnz 0      3 0
    std.debug.print("\n", .{});
}
