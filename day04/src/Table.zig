const std = @import("std");
const aoc = @import("aoc");

data: []const u8,
width: usize,

pub inline fn init(fd: aoc.FileData) @This() {
    const width = std.mem.indexOf(u8, fd.file_data, "\n") orelse unreachable;
    return .{
        .width = width + 1,
        .data = fd.file_data,
    };
}

pub inline fn get(self: *const @This(), x: usize, y: usize) u8 {
    std.debug.assert(x < self.width - 1 and y < self.width - 1);
    return self.data[x + y * self.width];
}
