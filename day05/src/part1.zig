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
fn lessThanPageNr(sorted_rules: []const Rule, l: u8, r: u8) bool {
    if (std.sort.binarySearch(Rule, r, sorted_rules, {}, compareRule)) |ri| {
        var r_ind = ri;
        while (r_ind > 0 and sorted_rules[r_ind - 1].before == r) {
            r_ind -= 1;
        }
        while (r_ind < sorted_rules.len and sorted_rules[r_ind].before == r) : (r_ind += 1) {
            const cant_be_before = sorted_rules[r_ind].after;
            if (l == cant_be_before) return false;
        }
    }

    return true;
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
        const valid = std.sort.isSorted(u8, page.items, rules.items, lessThanPageNr);
        if (valid) {
            const middle = page.items[page.items.len / 2];
            sum += middle;
        }
    }

    return sum;
}
