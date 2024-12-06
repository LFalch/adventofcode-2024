const std = @import("std");
const aoc = @import("aoc");

var data_buf: [20_000]u8 = undefined;

data: []u8,
width: usize,

pub inline fn init(fd: aoc.FileData) @This() {
    const width = std.mem.indexOf(u8, fd.file_data, "\n") orelse unreachable;
    @memcpy(data_buf[0..fd.file_data.len], fd.file_data);
    return .{
        .width = width + 1,
        .data = data_buf[0..fd.file_data.len],
    };
}

pub inline fn get(self: *const @This(), x: usize, y: usize) u8 {
    std.debug.assert(x < self.width - 1 and y < self.width - 1);
    return self.data[x + y * self.width];
}
pub inline fn get_mut(self: *const @This(), x: usize, y: usize) *u8 {
    std.debug.assert(x < self.width - 1 and y < self.width - 1);
    return &self.data[x + y * self.width];
}
