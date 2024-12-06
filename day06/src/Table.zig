const std = @import("std");
const aoc = @import("aoc");

data: []u8,
width: usize,

pub fn init(alloc: std.mem.Allocator, fd: aoc.FileData) @This() {
    const width = std.mem.indexOf(u8, fd.file_data, "\n") orelse unreachable;
    return .{
        .width = width + 1,
        .data = alloc.dupe(u8, fd.file_data) catch unreachable,
    };
}
pub fn deinit(self: @This(), alloc: std.mem.Allocator) void {
    alloc.free(self.data);
}
pub fn copy(self: *const @This(), alloc: std.mem.Allocator) @This() {
    return .{
        .width = self.width,
        .data = alloc.dupe(u8, self.data) catch unreachable,
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
