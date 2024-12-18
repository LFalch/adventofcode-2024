const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    var gpa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer _ = gpa.deinit();
    try aoc.main_with_bench(u64, .{gpa.allocator()}, solve);
}

fn solve(fd: aoc.FileData, ctx: struct { std.mem.Allocator }) u64 {
    var f = fd;

    std.debug.assert(f.accept("Register A: "));
    const reg_a = f.read_number(u64);
    std.debug.assert(f.accept("\nRegister B: "));
    const reg_b = f.read_number(u64);
    std.debug.assert(f.accept("\nRegister C: "));
    const reg_c = f.read_number(u64);
    _ = f.read_space();
    std.debug.assert(f.accept("Program: "));
    var program = std.ArrayList(u3).init(ctx[0]);
    defer program.deinit();

    while (true) {
        const n: u3 = @intCast(f.read_number(u8));
        program.append(n) catch unreachable;
        if (!f.accept(",")) break;
    }

    var longest_a: u64 = 0;
    var longest: u8 = 0;
    _ = reg_a;
    _ = reg_b;
    _ = reg_c;
    std.debug.print("=>{d}\n", .{program.items.len});
    for (222_100_475_547_978_046..std.math.maxInt(u64)) |a| {
        const length = test_program_hc(a, program.items);
        if (length >= longest) {
            std.debug.print("a: {d} => {d}\n", .{ a, length });
        }
        if (length > longest) {
            longest_a = a;
            longest = length;
        }
        if (longest == program.items.len) break;
    }
    return longest_a;
}

fn test_program(a: u64, b: u64, c: u64, program: []const u3) u8 {
    var reg_a = a;
    var reg_b = b;
    var reg_c = c;

    var pc: u8 = 0;
    var out_head: u8 = 0;

    while (pc < program.len) {
        const opcode = program[pc];
        const operand = program[pc + 1];
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
            5 => {
                const out = combo & 7;
                if (out_head < program.len) {
                    if (program[out_head] != out) {
                        return out_head;
                    }
                    out_head += 1;
                } else return out_head;
            },
        }
    }

    return out_head;
}

fn test_program_hc(a: u64, program: []const u3) u8 {
    var ra = a;

    var out_head: u8 = 0;

    while (ra != 0) {
        const a1 = ra;
        ra = a1 >> 3;

        const out = ((a1 & ~@as(u64, 7) | 5) >> std.math.lossyCast(u6, (a1 & 7) ^ 1)) & 7;
        if (out_head < program.len) {
            if (program[out_head] != out) {
                return out_head;
            }
            out_head += 1;
        } else return out_head;
    } // jnz 0      3 0

    return out_head;
}
