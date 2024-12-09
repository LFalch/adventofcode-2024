const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    var gpa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer gpa.deinit();
    try aoc.main_with_bench(usize, .{gpa.allocator()}, solve);
}

const FREE_BLOCK: u16 = std.math.maxInt(u16);

fn solve(fd: aoc.FileData, ctx: struct { std.mem.Allocator }) usize {
    const alloc = ctx[0];

    var disk = std.ArrayList(u16).init(alloc);
    defer disk.deinit();
    var file_id: u16 = 0;
    var free_space = false;

    for (fd.file_data) |c| {
        if (c == '\n') break;
        const d = c - '0';
        const space = disk.addManyAsSlice(d) catch unreachable;
        if (free_space) {
            @memset(space, FREE_BLOCK);
        } else {
            @memset(space, file_id);
            file_id += 1;
        }
        free_space = !free_space;
    }

    var checksum: usize = 0;

    var i: usize = 0;
    var j: usize = disk.items.len - 1;
    while (disk.items[j] == FREE_BLOCK) j -= 1;
    while (true) : (i += 1) {
        if (disk.items[i] == FREE_BLOCK) {
            if (i >= j) break;
            const new_value = disk.items[j];
            disk.items[i] = new_value;

            checksum += new_value * i;

            disk.items[j] = FREE_BLOCK;
            j -= 1;
            while (disk.items[j] == FREE_BLOCK) j -= 1;
        } else {
            checksum += disk.items[i] * i;
        }
    }

    return checksum;
}
