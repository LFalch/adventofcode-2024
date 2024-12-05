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

fn lessThanRule(_: void, l: Rule, r: Rule) bool {
    return std.sort.asc(u8)({}, l.before, r.before);
}
fn compareRule(_: void, key: u8, mid_item: Rule) std.math.Order {
    return std.math.order(key, mid_item.before);
}

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

    std.mem.sortUnstable(Rule, rules.items, {}, lessThanRule);

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
            if (std.sort.binarySearch(Rule, nr, rules.items, {}, compareRule)) |ri| {
                var r_ind = ri;
                while (r_ind > 0 and rules.items[r_ind - 1].before == nr) {
                    r_ind -= 1;
                }
                while (r_ind < rules.items.len and rules.items[r_ind].before == nr) : (r_ind += 1) {
                    const cant_be_before = rules.items[r_ind].after;
                    if (std.mem.indexOf(u8, page.items[0..i], &[_]u8{cant_be_before})) |_| {
                        valid = false;
                        break;
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
