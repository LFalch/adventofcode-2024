const std = @import("std");
const aoc = @import("aoc");

const Key = struct { u64, u8 };

pub fn solve(fd: aoc.FileData, alloc: std.mem.Allocator, blinks: u8, cap: u32) usize {
    var f = fd;

    var map = std.AutoHashMap(Key, usize).init(alloc);
    defer map.deinit();
    map.ensureUnusedCapacity(cap) catch unreachable;

    var total: usize = 0;
    while (!f.is_done()) {
        const stone = f.read_number(u64);
        _ = f.read_space();
        total += stones_after(stone, blinks, &map);
    }

    return total;
}

fn stones_after(stone: u64, blinks: u8, map: *std.AutoHashMap(Key, usize)) usize {
    if (blinks == 0) return 1;
    if (map.get(.{ stone, blinks })) |amnt| {
        return amnt;
    }

    const amnt = if (stone == 0)
        stones_after(1, blinks - 1, map)
    else if (split_factor(stone)) |factor|
        stones_after(stone % factor, blinks - 1, map) +
            stones_after(stone / factor, blinks - 1, map)
    else
        stones_after(stone * 2024, blinks - 1, map);
    map.put(.{ stone, blinks }, amnt) catch unreachable;
    return amnt;
}

fn split_factor(n: u64) ?u64 {
    return if (n < 10) null else if (n < 100) 10 else if (n < 1000) null else if (n < 10000) 100 else if (n < 100000) null else if (n < 1000000) 1000 else if (n < 10000000) null else if (n < 100000000) 10000 else if (n < 1000000000) null else if (n < 10000000000) 100000 else if (n < 100000000000) null else if (n < 1000000000000) 1000000 else if (n < 10000000000000) null else if (n < 100000000000000) 10000000 else if (n < 1000000000000000) null else if (n < 10000000000000000) 100000000 else if (n < 100000000000000000) null else if (n < 1000000000000000000) 1000000000 else if (n < 10000000000000000000) null else 10000000000;
}
