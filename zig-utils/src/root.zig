const std = @import("std");
const testing = std.testing;

var file_buf: [32 * 1024]u8 = undefined;

pub fn read_input() !FileData {
    const f = try std.fs.cwd().openFile("input.txt", .{ .mode = .read_only });
    defer f.close();
    const n = try f.readAll(&file_buf);
    return .{
        .file_data = file_buf[0..n],
    };
}

pub const FileData = struct {
    file_data: []u8,

    pub fn is_done(self: *const FileData) bool {
        return self.file_data.len == 0;
    }

    /// returns if the space was a newline
    pub fn read_space(self: *FileData) bool {
        var n: usize = 0;
        var isNewline = true;
        while (n < self.file_data.len) : (n += 1) {
            const c = self.file_data[n];
            if (!std.ascii.isWhitespace(c)) break;
            if (c != '\n') isNewline = false;
        }

        self.file_data = self.file_data[n..];
        return isNewline;
    }

    pub fn read_number(self: *FileData, int: type) int {
        var out: int = 0;
        var n: usize = 0;
        while (n < self.file_data.len) : (n += 1) {
            const c = self.file_data[n];
            if (!std.ascii.isDigit(c)) break else {
                out = out * 10 + c - '0';
            }
        }

        self.file_data = self.file_data[n..];
        return out;
    }
};
