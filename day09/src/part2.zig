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

    var fid = file_id - 1;
    var j: usize = disk.items.len - 1;
    outer: while (fid > 0) : (fid -= 1) {
        while (disk.items[j] != fid) j -= 1;
        var i = j;
        while (disk.items[i - 1] == fid) i -= 1;
        const end = j + 1;
        j = i - 1;

        var free_i: usize = 0;
        var free_j = end - i;
        while (free_j <= i) {
            const free_space_candidate = disk.items[free_i..free_j];
            if (std.mem.lastIndexOfNone(u16, free_space_candidate, &[_]u16{FREE_BLOCK})) |next_free_i| {
                free_i += next_free_i + 1;
                free_j += next_free_i + 1;
            } else {
                // found free space!
                @memset(free_space_candidate, fid);
                for (free_i..free_j) |pos| {
                    checksum += fid * pos;
                }
                continue :outer;
            }
        }

        // sum_(n=a)^(b - 1) n = 1/2 (b - a) (a + b - 1)
        checksum += fid * (((end - i) * (i + end - 1)) / 2);
    }

    return checksum;
}
