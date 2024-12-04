const std = @import("std");
const aoc = @import("aoc");
const Table = @import("Table.zig");

pub fn main() !void {
    try aoc.main_with_bench(u32, {}, solve);
}

fn solve(fd: aoc.FileData, _: void) u32 {
    const table = Table.init(fd);
    const width = table.width - 1;

    var count: u32 = 0;

    for (0..width - 2) |y| {
        for (0..width - 2) |x| {
            if (table.get(x + 1, y + 1) != 'A') continue;
            const ll = table.get(x, y);
            const rr = table.get(x + 2, y + 2);
            if (!((ll == 'M' and rr == 'S') or (ll == 'S' and rr == 'M')))
                continue;
            const rl = table.get(x + 2, y);
            const lr = table.get(x, y + 2);
            if (!((lr == 'M' and rl == 'S') or (lr == 'S' and rl == 'M')))
                continue;
            count += 1;
        }
    }

    return count;
}
