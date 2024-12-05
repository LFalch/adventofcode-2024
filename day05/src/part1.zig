const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    try aoc.main_with_bench(u32, .{gpa.allocator()}, solve);
}

const Rule = struct {
    before: u8,
    after: u8,
};

fn solve(fd: aoc.FileData, ctx: struct { std.mem.Allocator }) u32 {
    const alloc = ctx[0];
    var f = fd;

    var rules = std.ArrayList(Rule).init(alloc);
    defer rules.deinit();
    while (true) {
        const before = f.read_number(u8);
        if (before == 0) break;
        std.debug.assert(f.accept("|"));
        const after = f.read_number(u8);
        std.debug.assert(f.accept("\n"));
        rules.append(.{ .before = before, .after = after }) catch unreachable;
    }
    std.debug.assert(f.read_space());
    var sum: u32 = 0;
    nr_loop: while (true) {
        var page = std.ArrayList(u8).init(alloc);
        defer page.deinit();

        while (true) {
            const nr = f.read_number(u8);
            if (nr == 0) break :nr_loop;
            page.append(nr) catch unreachable;
            if (!f.accept(",")) break;
        }
        std.debug.assert(f.read_space());

        // validate page
        var valid = true;
        for (page.items, 0..) |nr, i| {
            for (rules.items) |rule| {
                if (rule.before == nr) {
                    for (page.items[0..i]) |prev_nr| {
                        if (rule.after == prev_nr) {
                            valid = false;
                            break;
                        }
                    }
                }
            }
        }
        if (valid) {
            const middle = page.items[page.items.len / 2];
            sum += middle;
        }
    }

    return sum;
}
